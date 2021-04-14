#include <QQuickItem>
#include <QSGMaterial>
#include <QSGMaterialShader>
#include <QSGGeometry>
#include <QSGNode>
#include <QSGGeometryNode>
#include <private/qshaderbaker_p.h>

#include "sink.h"

Sink::Sink() {
    ma_rb_init(4*PERIOD*sizeof(double), NULL, NULL, &ringbuf);
    func = new Func;
}


struct UniformBlock {
    float matrix[16];
    float opacity;
    float time;
    int32_t vmax;
    int32_t vidx;
    float volts[PERIOD];
}
#ifdef __GNUC__
classdef __attribute__((__packed__));
#else
__pragma( pack(push, 1) )
classdef;
__pragma( pack(pop) )
#endif

QString uniformHeader = QString(R"(
layout(std140, binding = 0) uniform buf {
  mat4 qt_Matrix;
  float qt_Opacity;
  float time;
  int vmax;
  int vidx;
  vec4 volts[%1];
} u;
)").arg(PERIOD/4);

QString vertHeader(R"(#version 440
layout(location = 0) in vec4 aVertex;
layout(location = 1) in vec2 aTexCoord;
layout(location = 0) out vec2 vTexCoord;
)");

QString fragHeader(R"(#version 440
layout(location = 0) in vec2 fragCoord;
layout(location = 0) out vec4 fragColor;
)");

QString vertDefault = QString(R"(
void main() {
  gl_Position = ubuf.qt_Matrix * aVertex;
  vTexCoord = aTexCoord;
}
)");

QString fragDefault = QString(R"(
void main() {
  fragColor = vec4(0,0,0,0);
}
)");



class Shader : public QSGMaterialShader {

   
    public:
        ShaderSink *sink;
        Shader(ShaderSink *sink) : sink(sink){
            sink->setStatus("");
            setShader(VertexStage, compile(vertHeader+uniformHeader, sink->vertCode, vertDefault, QShader::VertexStage, QShader::BatchableVertexShader, sink));
            setShader(FragmentStage, compile(fragHeader+uniformHeader, sink->fragCode, fragDefault, QShader::FragmentStage, QShader::StandardShader, sink));
        }    
           
        QShader compile(QString head, QString src, QString backup, QShader::Stage stage, QShader::Variant variant, ShaderSink *sink) {
            QShaderBaker baker;
            baker.setGeneratedShaderVariants({variant});
            baker.setSourceString((head+src).toUtf8(), stage);
            baker.setGeneratedShaders({{QShader::SpirvShader, 100},
                                       {QShader::GlslShader, QShaderVersion(100, QShaderVersion::GlslEs)},
                                       {QShader::HlslShader, QShaderVersion(50)},
                                       {QShader::MslShader, QShaderVersion(12)}});
            QShader shader = baker.bake();
            if (!shader.isValid()) {
                sink->setStatus(sink->getStatus() + baker.errorMessage());
                qDebug().noquote() << baker.errorMessage();                
                baker.setSourceString((head+backup).toUtf8(), stage);
                shader = baker.bake();
            }
            return shader;
        }
    
        bool updateUniformData(RenderState &state, QSGMaterial *, QSGMaterial *) override {
            QByteArray *buf = state.uniformData();
            if (buf->size() < sizeof(UniformBlock)) {
                qDebug() << "uniform buffer too small!";
                return false;
            }
            UniformBlock *u = (UniformBlock*) buf->data();
            const QMatrix4x4 m = state.combinedMatrix();
            memcpy(u->matrix, m.constData(), 64);
            u->opacity = state.opacity();
            u->time = ((double)maestro.ticks) / maestro.sym_s;
            u->vmax = PERIOD;
            u->vidx = u->vidx % PERIOD;
            int frames_to_read = PERIOD;
            while (frames_to_read > 0) {
                void *chunk;
                size_t nbytes = frames_to_read * sizeof(double);
                ma_rb_acquire_read(&sink->ringbuf, &nbytes, &chunk);
                int nv = nbytes / sizeof(double);
                double* vchunk = (double*) chunk;
                for (int f = 0; f < nv; f++) {
                    u->volts[u->vidx] = vchunk[f];
                    u->vidx = (u->vidx + 1) % PERIOD;
                }
                ma_rb_commit_read(&sink->ringbuf, nbytes, chunk);
                frames_to_read -= nv;
                if (nbytes == 0) break;
            }
            return true;   
        }
};



class Material : public QSGMaterial {
    public:
        static QSGMaterialType *clean;
        ShaderSink *sink;
        Material(ShaderSink* sink) : sink(sink) {};
        QSGMaterialType *type() const override {
            if (clean) return clean;
            clean = new QSGMaterialType;
            return clean;
        }
        QSGMaterialShader *createShader(QSGRendererInterface::RenderMode) const override {
            qDebug() << "material creates shader";
            return new Shader(sink);
        }
};

QSGMaterialType* Material::clean = nullptr;



ShaderSink::ShaderSink(QQuickItem *parent) : QQuickItem(parent), Sink(), vertCode(vertDefault), fragCode(fragDefault), recompile(true), status("") {
    setFlag(ItemHasContents, true);
    maestro.audio->addSink(this);
}

ShaderSink::~ShaderSink() {
    maestro.audio->removeSink(this);
}

QString ShaderSink::getStatus() {
    return status;
}

void ShaderSink::setStatus(QString s) {
    status = s;
    emit statusChanged();
}

Q_INVOKABLE void ShaderSink::setFunc(QObject *function) {
    maestro.audio->pause();
    if (function == nullptr) func = new Func;
    else func = qobject_cast<QFunc*>(function);
    maestro.audio->resume();
}

QSGNode* ShaderSink::updatePaintNode(QSGNode *old, UpdatePaintNodeData *) {
    auto *node = static_cast<QSGGeometryNode *>(old);
    if (!node || recompile) {
        node = new QSGGeometryNode();
        Material::clean = nullptr;
        auto *m = new Material(this);
        node->setMaterial(m);
        node->setFlag(QSGGeometryNode::OwnsMaterial, true);
        QSGGeometry *g = new QSGGeometry(QSGGeometry::defaultAttributes_TexturedPoint2D(), 4);
        QSGGeometry::updateTexturedRectGeometry(g, QRect(0,0,width(),height()), QRect(0,0,1,1));
        node->setGeometry(g);
        node->setFlag(QSGGeometryNode::OwnsGeometry, true);
        recompile = false;
    }
    node->markDirty(QSGGeometryNode::DirtyMaterial);
    return node;
}

Q_INVOKABLE void ShaderSink::run(QString vert, QString frag) {
    vertCode = vert;
    fragCode = frag;
    recompile = true;
}
