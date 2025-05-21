ServerOptions.inDevices;
ServerOptions.outDevices;

/*(
o = Server.default.options;
o.inDevice_("ASIO : ASIO MADIface USB");
o.outDevice_("ASIO : ASIO MADIface USB");
s.options.sampleRate = 48000;
Server.default.reboot;
MIDIIn.connectAll;
)*/


o = Server.default.options;
o.inDevice_("MME : IN 1-2");
o.outDevice_("MME : OUT 1-2");
Server.default.reboot;
MIDIIn.connectAll;


// BUFFERS
~bufs = { Buffer.alloc(s, s.sampleRate * 4) } ! 8;
Buffer.freeAll;

// RECORD
(
SynthDef(\record, {
	arg trig = 0, loop = 1, buf;
	var sig = SoundIn.ar(0);
	RecordBuf.ar(sig, buf, preLevel: 1, run: trig, loop: loop, trigger: trig, doneAction: 0);
	Silent.ar;
}).add;
)
{SoundIn.ar(0, 1)}.play
(
~recSynths = 8.collect{arg i; Synth(\record, [buf: ~bufs[i], trig: 0, loop: 1], addAction: \addAfter)};

~numRec = 0 ! 8;

~updateRec = {
	arg i;
	// i.postln;
	if(~numRec[i] == 0)
	{
		~recSynths[i].set(\trig, 1);
		~numRec[i] = ~numRec[i] + 1;
	}
	{
		~recSynths[i].set(\trig, 0);
		~numRec[i] = ~numRec[i] - 1;
	};
	~numRec[i];
};

~makeRecorders = (64..71).collect{arg i; MIDIFunc.cc({arg ...args; ~updateRec.(args[1]-64)}, i)}; //record
)

// ~bufs[0].play
// 8.collect{arg i; ~bufs[i].zero};

///PLAYBUF

(
SynthDef(\test, {
	arg trig = 0, buf = 0, out = 0, freq = 400, mute = 0, rate = 1, velocity = 0, startPos = 0, high = 20 , low = 12000;
	var play, trigVel;
	trigVel = if(velocity == 0)
	{
		trigVel = trig;

	}
	{
		SinOsc.kr(velocity) * trig;
	};
	play = PlayBuf.ar(
		numChannels: 1,
		bufnum: buf,
		rate: rate,
		trigger: trigVel,
		startPos: startPos,
		loop: trig,
		doneAction: 0);
	play = HPF.ar(play, high.lag);
	play = LPF.ar(play, low.lag);
	Out.ar(out, play);
}).add;
)

~playbufSynths = 8.collect{ arg i; Synth(\test, [buf: ~bufs[i], trig: 0, mute: 0])};


//PLAY
(
~updatePlay = {arg numPlay;
	if(numPlay == 127)
	{
		~playbufSynths.do{arg synth; synth.set(\trig, 1)};
	}
	{
		~playbufSynths.do{arg synth; synth.set(\trig, 0)};
	};
};

~makePlay = MIDIFunc.cc({arg ...args;
	// args.postln;
	~updatePlay.(args[0])}, 41); //?
)


//MUTE
(
~numMute = 0 ! 8;

~updateMute = {
	arg i;
	if(~numMute[i] == 0)
	{
		~playbufSynths[i].set(\trig, 0);
		~numMute[i] = ~numMute[i] + 1;
	}
	{
		~playbufSynths[i].set(\trig, 1);
		~numMute[i] = ~numMute[i] - 1;
	};
};
~makeMute = (48..55).collect{arg i; MIDIFunc.cc({arg ...args; ~updateMute.(args[1]-48)}, i)}; //mute
)


//SOLO (SKETCH)
(
~numSolo = 0 ! 8;
~updateSolo = {
	arg i;
	if(~numSolo[i] == 0)
	{
		~playbufSynths.do{
			arg synth, j;
			if(j == i)
			{synth.set(\trig, 1);}
			{synth.set(\trig, 0);}
		};
		~numSolo[i] = ~numSolo[i] + 1;
	}
	{
		~playbufSynths.do{arg synth; synth.set(\trig, 1)};
		~numSolo[i] = ~numSolo[i] - 1;
	}
};
~makeSolo = (32..39).collect{arg i; MIDIFunc.cc({arg ...args; ~updateSolo.(args[1]-32)}, i)}; //mute
)

// MIDIFunc.trace(false)

//REVERSE
(
MIDIFunc.cc({arg ...args; ~playbufSynths.do{arg synth; synth.set(\rate, args[0].linlin(0, 127, 1, -1))};}, 0);
)

//HIGH AND LOW PASS
(
MIDIFunc.cc({arg ...args; ~playbufSynths.do{arg synth; synth.set(\high, args[0].linlin(0, 127, 20, 12000))}}, 1);

MIDIFunc.cc({arg ...args; ~playbufSynths.do{arg synth; synth.set(\low, args[0].linlin(0, 127, 12000, 20))}}, 2);
)

//VELOCITY
(
MIDIFunc.cc({arg ...args; ~playbufSynths.do{arg synth; synth.set(\velocity, args[0].linlin(0, 127, 0, 20))}}, 3);
)

//START POSITION
(
MIDIFunc.cc({arg ...args; ~playbufSynths.do{arg synth; synth.set(\startPos, args[0].linlin(0, 127, 0, 176400))}}, 4);
)