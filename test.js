

msgs = `controls[1]=-2.1969914925867418
controls[2]=-0.534947807288976
controls[3]=-2.201928452151149
controls[4]=-3.2096868437338735
controls[5]=-3.38951589996703
controls[6]=-4.13556017406374
controls[7]=1.300541120566363
controls[8]=6.666666666666668
controls[8]=6.666666666666668
controls[9]=-5.3330215410084385
controls[10]=-0.625
controls[10]=-0.625
controls[11]=0.0032913063762745054
controls[12]=-2.228060104084358
controls[13]=-4.300777150680637
controls[14]=0.24381073149348786
controls[15]=4.773587734974392
controls[16]=2.5193959789568154
controls[17]=2.2739395942751983
controls[18]=4.104491562566135
controls[19]=-0.02777730512134724
controls[20]=5.707689331244936
streams[0]=((((((2 * (1.38)^(((((((0)+(0)+control(19))) + ((2 * (1.35)^((0)+control(18))))*ramps((((smaller(mod(t,(1/((100/mins * (1.2)^((0)+control(20)))))),10ms) ? (10v) : 0))),0v,1v,((100ms * (2)^((0)+control(14)))),((1 * (4)^((0)+control(16)))),0v,((100ms * (2)^((0)+control(15)))),((1 * (4)^((0)+control(17))))))))+control(2))))*sinusoid(((notehz(C,4) * (2)^((((((1 * (1.25)^((0)+control(11)))) * sequence((((smaller(mod(t,(1/((100/mins * (1.2)^((0)+control(20)))))),10ms) ? (10v) : 0))),randsample((minorBlues),(16),((666 * (2)^((0)+control(9)))))))))+control(1))))))) + ((((2 * (1.38)^(((((((0)+(0)+control(19))) + ((2 * (1.35)^((0)+control(18))))*ramps((((smaller(mod(t,(1/((100/mins * (1.2)^((0)+control(20)))))),10ms) ? (10v) : 0))),0v,1v,((100ms * (2)^((0)+control(14)))),((1 * (4)^((0)+control(16)))),0v,((100ms * (2)^((0)+control(15)))),((1 * (4)^((0)+control(17))))))))+control(5)))) * pwm(((notehz(C,4) * (2)^(((slew((((((1 * (1.25)^((0)+control(11)))) * sequence((((smaller(mod(t,(1/((100/mins * (1.2)^((0)+control(20)))))),10ms) ? (10v) : 0))),randsample((minorBlues),(16),((666 * (2)^((0)+control(9))))))))),((2ms * (2)^((0)+control(6)))),(((-1)+(0)+control(7)))/7)))+control(3)))),(((10)+(0)+control(4)))/20))))/2)`.split('\n')

const cp = require('child_process');
subproc = cp.fork('./ohm.js');
for (let msg of msgs) {
    console.log(msg)
    subproc.send(msg)
}




