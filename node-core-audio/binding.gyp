{
	'targets': [
		{
			'target_name': 'NodeCoreAudio',
			'sources': [
				'NodeCoreAudio/AudioEngine.cpp',
				'NodeCoreAudio/NodeCoreAudio.cpp',
			],
			'include_dirs': [
                "<!(node -e \"require('nan')\")",
				'<(module_root_dir)/NodeCoreAudio/',
				'<(module_root_dir)/portaudio/'
			],
			"conditions" : [
				[
					'OS=="mac"', {
						"libraries" : [
							'<(module_root_dir)/gyp/lib/libportaudio.a',
							'/Library/Frameworks/CoreAudio.framework',
							'/Library/Frameworks/AudioToolbox.framework',
							'/Library/Frameworks/AudioUnit.framework',
							'/Library/Frameworks/CoreServices.framework',
							'/Library/Frameworks/Carbon.framework'
						],
						'cflags!': [ '-fno-exceptions' ],
						'cflags_cc!': [ '-fno-exceptions' ],
						'cflags_cc': [ '-std=c++0x' ]
					}
				]
			]
		}
	]
}
