//server
(
s.options.device = "ASIO : ASIO MADIface USB";

s.options.numOutputBusChannels = 32;

s.options.sampleRate = 48000;

s.reboot;
)


//BVAP buffer
(
~vbapArray = VBAPSpeakerArray.new(3, [
	[0, 0], [20, 0], [45, 0], [70, 0], [100, 0], [140, 0], [180, 0], [-140, 0], [-100, 0], [-70, 0], [-45, 0], [-20, 0],
	[20, 40], [65, 40], [115, 40], [160, 40], [-160, 40], [-115, 40], [-65, 40], [-20, 40],
	[45, 80], [135, 80], [-135, 80], [-45, 80]
]);

~vbapBuffer = ~vbapArray.loadToBuffer(s);
)


//GUIs
(
SynthDef(\sinner_add,
	{
		|midis = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		midiAmps = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		add = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		add2 = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		amp = 0.1,
		shift = 0,
		out = 1|
		var midis2 = midis + shift;
		var src = SinOsc.ar(midis2.midicps, 0, midiAmps).sum * amp;
		var src2 = SinOsc.ar(
			(
				add = midis2.midicps + add;
				add = if (add == midis2) {0} {add};
		), 0 , midiAmps).sum * amp;
		var src3 = SinOsc.ar(
			(
				add2 = midis2.midicps + add2;
				add2 = if (add2 == midis2) {0} {add2};
		), 0 , midiAmps).sum * amp;
		Out.ar(out, src + src2 + src3);
	},
	metadata: (
		specs: (
			midis: [24, 120, \lin, 1, 38],
			midiAmps: [0, 1, \lin, 0, 0],
			add: [0, 10, \lin, 0.1, 0],
			add2: [0, 15, \lin, 0.1, 0],
			amp: [0, 1, \db, 0, 0.05],
			shift: [-20, 20, \lin, 1, 0]
		)
	)
).add;


~inBus = Bus.audio(s, 1);

SynthDef(\mic_in,
	{
		var src, in = 0, out = ~inBus;
		src = SoundIn.ar(in);
		Out.ar(out, src);
}).add;


~spatOffset = 4;

SynthDef(\spat, { |out = 0, moveFreq = 0.05, spread = 0, mix = 1,
	resampleRate = 24000, resampleLag = 10, bitDepth = 24, delayTime = 0, preAmp = 2, limitAmp = 0.2|
	var inSig = In.ar(~inBus, 1), inSig2, movingSig, sigMix;

	inSig = DelayL.ar(inSig, 10, delayTime.lag(0.000001));
	inSig2 = Latch.ar(inSig, Impulse.ar(resampleRate.lag(resampleLag))).round(2 ** (1 - bitDepth));
	sigMix = LinXFade2.ar(inSig, inSig2, 2 * mix - 1);


	movingSig = VBAP.ar(
		24,
		sigMix,
		~vbapBuffer,
		LFDNoise3.kr(moveFreq).range(-180, 180),
		LFDNoise3.kr(moveFreq).range(0, 60),
		spread
	);

	movingSig = Limiter.ar(movingSig * preAmp, limitAmp.lag(0.5), 0.05);
	Out.ar(~spatOffset + out, movingSig) ;
}, metadata: (
	specs: (
		resampleRate: [1, 2400, \lin, 1, 4],
		resampleLag: [0, 10000, \lin, 1, 250],
		bitDepth: [1, 32, \lin, 1, 24],
		mix: [0, 1, \lin, 0, 0],
		delayTime: [0, 8, \lin, 0.001, 0.111],
		spread: [0, 100, \lin, 0, 3],
		moveFreq: [0, 20, \lin, 0, 0.3],
		preAmp: [0, 6, \lin, 0, 0],
		limitAmp: [0, 0.6, 2, 0, 0],
	)
)
).add;
)

m = Synth(\mic_in)
[\sinner_add, \mic_in, \spat].sVarGui.gui(tryColumnNum: 5)