//iter
(
SynthDef(\iter,
	{
		arg freq = 40, atk = 0.005, rel = 0.3, amp = 1, pan = 0, out = 0, dev = 0.01;
		var temp, sum, env;
		sum = 0;
		env = EnvGen.kr(Env([0, 1, 0], [atk, rel], [1, -1]), doneAction: 2);
		10.do{
			temp = VarSaw.ar(
				freq * {Rand(1-dev, 1)}!2,
				{Rand(0, 1.0)}!2,
				{ExpRand(0.005, 0.05)}!2
			);
			sum = sum + temp;
		};
		sum = sum * env;
		sum = Balance2.ar(sum[0], sum[1], pan, amp * 0.05); //danger!
		//sum = Pan2.ar(sum, pan, amp * 0.05);
		Out.ar(out, sum);
}).add
)


(
//mid
a = Pbind(
	\instrument, \iter,
	\dur, Pseq([
		0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 3,
		0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1, 0.5 , 1.5,
	], inf),
	\midinote, Pseq([
		58, 68, 67, 58, 65, 63,
		58, 68, 67, 58, 65, 63,
		61, 63, 65, 60, 61, 63, 58,
		58, 68, 67, 58, 65, 63,
		58, 68, 67, 58, 65, 63,
		60, 61, 63, 59, 61, 63, 58, 60, 58,
	], inf),
	\dev, 0.001,
	\rel, Pseq([
		0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 3,
		0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1, 0.5 , 1.5,
	] + 0.5, inf),
	\amp, 0.4,
);

//mid-low
b = Pbind(
	\instrument, \iter,
	\dur, Pseq([
		9,
		2 + (3/6), 1/6, 1/6, 1/6,
		//2 + (4/8), 1/8, 1/8, 2/8,
		1.5, 1.5, 3,
		5 + (2/3), 1/3,
		5 + (2/3), 1/3,
		3, 3,
	], inf),
	\midinote, Pseq([
		51,
		51, 51, 53, 55,
		49, 48, 46,
		51, 53,
		51, 53,
		58, 46,
		] - 12, inf),
	\dev, 0.03,
	\rel, Pseq([
		9,
		2 + (3/6), 1/6, 1/6, 1/6,
		//2 + (4/8), 1/8, 1/8, 2/8,
		1.5, 1.5, 3,
		5 + (2/3), 1/3,
		5 + (2/3), 1/3,
		3, 3,
	] + 0.5, inf),
	\amp, 0.2,
);
//
c = Pbind(
	\instrument, \iter,
	\dur, Pseq([
		9,
		2 + (3/6), 1/6, 1/6, 1/6,
		//2 + (4/8), 1/8, 1/8, 2/8,
		1.5, 1.5, 3,
		5 + (2/3), 1/3,
		5 + (2/3), 1/3,
		3, 3,
	], inf),
	\midinote, Pseq([
		51,
		51, 51, 53, 55,
		49, 48, 46,
		51, 53,
		51, 53,
		58, 46,
	] - (12*2), inf),
	\dev, 0.01,
	\rel, Pseq([
		9,
		2 + (3/6), 1/6, 1/6, 1/6,
		//2 + (4/8), 1/8, 1/8, 2/8,
		1.5, 1.5, 3,
		5 + (2/3), 1/3,
		5 + (2/3), 1/3,
		3, 3,
	] + 0.5, inf),
	\amp, 0.7,
)
)


[0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 3,
		0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 3.5,
		0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1, 0.5 , 1.5,].sum

a = Pfindur (72, a);
b = Pfindur (72, b);
c = Pfindur (72, c);

(
c = c.asScore(40, timeOffset: 0.001);
c.add([0.0, [\d_recv, SynthDescLib.global[\iter].def.asBytes]]);
c.sort;
c.recordNRT(
	outputFilePath: "~/mid_low_2.wav".standardizePath,
	sampleRate: 44100,
	headerFormat: "wav",
	sampleFormat: "int16",
	options: ServerOptions.new.numOutputBusChannels_(2),
	duration: 40
);
)


//


//multi
(
SynthDef(\multi, {
	arg freq = 100, atk = 0.05, rel = 1, amp = 1, out = 0;
	var sig, ampp, env;
	env = EnvGen.kr(Env([0, 1, 0], [atk, rel], [1, -1]), doneAction: 2);
	ampp = SinOsc.kr([2, 4, 3, 1, 50]).range(0, amp);
	sig = SinOsc.ar([freq * 3, freq * 5, freq * 2, freq]);
	sig = sig * env * ampp;
	//Mix.new(sig) ! 2 * 0.25;
	sig = Splay.ar(sig) * 0.05;
	Out.ar(0, sig);
}).add
)

//multi epxanded
(
SynthDef(\multi_lfos_3, {
    arg freq = 100, freqFactors = #[3, 5, 2, 1], ampModFreqs = #[2, 4, 3, 1, 50], atk = 0.05, rel = 1, amp = 1,
    lfoFreq = 0.1, lfoFreqDev = 0.01, /*dup = 4, */ lfoAmp = 0.1, lfoAmpDev = 0.01, out = 0;

    var sig, ampp, env, lfo1, lfo2;
    env = EnvGen.kr(Env([0, 1, 0], [atk, rel], [1, -1]), doneAction: 2);

    lfo1 = { LFDNoise3.ar(lfoFreq).range(1 - lfoFreqDev, 1 + lfoFreqDev) } ! 4;
	lfo2 = { LFDNoise3.ar(lfoAmp).range(1 - lfoAmpDev, 1 + lfoAmpDev) } ! 4;

	ampp = SinOsc.kr(ampModFreqs * lfo2).range(0, amp);
    sig = SinOsc.ar(freq * freqFactors * lfo1);
    sig = sig * env * ampp;
    //Mix.new(sig) ! 2 * 0.25;
    sig = Splay.ar(sig) * 0.05;
    Out.ar(0, sig);
}).add
)



//only pads
(
//long
a = Pbind(
	\instrument, \iter,
	\dur, 6,
	\midinote, Pseq([[0, 2, 7, 12], [0, 2, 7, 9], [0, 2, 5, 9], [0, 2, 9, 12], [0, 5, 7, 12, 14], [0, 2, 7, 12], [0, 2, 5, 7, 9, 12, 16]]+(12*4+10), inf),
	\dev, Pwrand([0.01, Pwhite(0.03, -0.03, 1)], [7.2368, 2.1238].normalizeSum, inf),
	\atk, 1.5,
	\rel, Pseq([Pn(5, 8), Pn(2.5, 5)], inf),
	\amp, Pwhite(0.09, 0.5),
	\pan, Pwhite(-0.7, 0.7)
);

//medium
b = Pbind(
	\instrument, \iter,
	\dur, 3,
	\midinote, Pseq([12, 10, 7, 9, 5, 7, 3, 2]+(12*3+10), inf),
	\dev, Pwrand([0.01, Pwhite(0.03, -0.03, 1)], [7.2368, 2.1238].normalizeSum, inf),
	\atk, 0.05,
	\rel, Pseq([Pn(5, 8), Pn(2.5, 5)], inf),
	\amp, Pwhite(0.09, 0.05),
);

//bass
c = Pbind(
	\instrument, \iter,
	\dur, 9,
	\midinote, Pseq([12, 10, 12, 7, 8, 7, 8, 3]+(12*2+10), inf),
	\atk, 0.05,
	\rel, Pseq([Pn(10, 15), Pn(2.5, 5)], inf),
	\amp, Pwhite(0.08, 0.1),
);

//lower texture
d = Pbind(
	\instrument, \multi,
	\dur, Pwhite(9, 18, inf),
	\midinote, Pseq([12, 0] + (12*2+10), inf),
	\atk, 4,
	\rel, 14,
	\amp, Pwhite(0.5, 0.9);
);

//text
e = Pbind(
	\instrument, \multi_lfos_3,
	\dur, 1/3,
	\midinote, Pseq([12, 12, 16, 9, 7, 5, 4, 7] + (12 * 4 + 10), inf),
	\freqFactors, Pseq([ [[3, 5, 2, 1]], [[5, 3, 2, 1]], [[4, 5, 3, 1]], [[3, 5, 9, -1]] ],inf),
	\ampModFreqs, Pseq([ [[2, 4, 3, 1, 50]], [[2, 4, 3, 1]], [[2, 4, 3, 1, 50]], [[2, 4, 3, 1]], [[2, 4, 3, 1, 50]], [[2, 4, 3, 1]], [[2, 2, 10, 1]], [[5, 3, 2.3, 3]], [[2.14, 4.3, 3, 2]] ],inf),
	\lfoFreq, Pwhite(0.001, 1),
	\lfoFreqDev, Pwrand([0.01, Pwhite(0.02, 0.04, 1)], [8.125687, 2.418].normalizeSum, inf),
	\lfoAmp, -5,
	\lfoAmpDev, Pwhite(-10, 10, inf),
	\atk, 2,
	\rel, 2,
	\amp, Pseg([0.05, 0.3, 0].normalizeSum, 5, repeats: inf);
);
)

