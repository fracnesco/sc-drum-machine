// panels/sdgchaos.scd - what the chaos drum's window shows (SynthVoiceWindow). The source
// pane draws each source's kind of motion (the logistic map is the real map at the tone's r);
// the dirt pane runs one cycle of the body through the drive, the fold and the crush.
(
var seg = { |t, len, c| if(t >= len) { 1 } { (1 - exp(c * t / len.max(0.0001))) / (1 - exp(c)) } };
var hash = { |k| var a = sin(k * 12.9898) * 43758.5453; a - a.floor };
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
// the four sources at u (0..1 of the picture), n steps across it
var sources = { |u, n, tone|
	var k = (u * n).floor, x = 0.5;
	var crackle = if(hash.(k + 0.37) > (0.82 - (tone * 0.2))) { (hash.(k) * 2 - 1).sign * (0.5 + (hash.(k + 9) * 0.5)) } { (hash.(k + 3) - 0.5) * 0.15 };
	var logistic, stepped = hash.(k + 17) * 2 - 1, gendy;
	(k.asInteger + 1).do { x = (3.72 + (tone * 0.27)) * x * (1 - x) };
	logistic = x * 2 - 1;
	gendy = { var j = (u * n / 4), j0 = j.floor, fr = j - j0, a = hash.(j0 + 31) * 2 - 1, b = hash.(j0 + 32) * 2 - 1;
		a + ((b - a) * (0.5 - (cos(fr * pi) * 0.5))) }.value;
	[crackle, logistic, stepped, gendy]
};
(
	colour: \aqua, drum: true,
	hint: "source - crackle, logistic map, stepped noise, gendy: a different motion under the noise and the body; tone runs it faster",
	links: (sdgdecay: [\sdgbend], sdgnoise: [\sdgtail]),
	panes: [
		(type: \stops, w: 1, title: "the chaotic source", names: ["crackle", "logistic", "stepped", "gendy"], pos: { |p| p[\sdgcolor] },
			glyph: { |u, pos, p| var s = sources.(u, 24 + (p[\sdgtone].clip(0, 1) * 56), p[\sdgtone].clip(0, 1)), x = pos * 3, i = x.floor.asInteger.min(2);
				blend(s[i], s[i + 1], x - i) * 0.9 },
			readout: { |p| "steps at % · tone runs it".format(SynthVoicePanes.format(1500 * (2 ** (p[\sdgtone] * 4)), "Hz")) }),
		(type: \pitch, w: 0.7, title: "body pitch", len: { |p| (p[\sdgbend] * 2.5).clip(0.05, 1.5) }, func: { |t, p| p[\sdgpunch] * (1 - (t / p[\sdgbend].max(0.001)).min(1)) },
			range: { |p| [-2, (p[\sdgpunch] * 1.15).max(4)] }, zero: "lands",
			readout: { |p| "% st in % · %".format(p[\sdgpunch].round(0.1), SynthVoicePanes.format(p[\sdgbend], "s"), hz.(p[\sdgfreq])) }),
		(type: \env, w: 0.9, title: "body, noise and comb", len: { |p| (max(p[\sdgdecay], p[\sdgnoise]) * 1.2 + (p[\sdgtail] * 0.5)).max(0.05) },
			curves: { |p| var snap = p[\sdgsnap].clip(0, 1), ringT = p[\sdgtail] * 0.5;
				[(func: { |t| snap * (1 - seg.(t, p[\sdgnoise], -6)) }, label: "noise"),
				(func: { |t| (1 - snap) * (1 - seg.(t, p[\sdgdecay], -4)) }, label: "body"),
				(func: { |t| if(ringT < 0.005) { 0 } { p[\sdgtail] * 0.6 * (1 - seg.(t, p[\sdgnoise] + ringT, -5)) } }, label: "comb", colour: \dim)] },
			readout: { |p| "% noise · comb %".format(pct.(p[\sdgsnap]), SynthVoicePanes.format(p[\sdgtail] * 0.5, "s")) }),
		(type: \wave, w: 0.7, title: "dirt", cycles: 1,
			func: { |ph, p| var d = p[\sdgdrive].clip(0, 1), b = p[\sdgbits].clip(0, 1);
				var n = (24000 * (2 ** (b * -4)) / p[\sdgfreq].max(30)).clip(3, 400), q = 2 ** (15 - (b * 13));
				var crush = { |x| (x * q).round / q }, drv = { |x| var y = (x * (1 + (d * 5))).tanh; blend(y, (y * 2.5).fold2(1), ((d - 0.5).max(0) * 2)) };
				var dry = drv.(sin(ph * 2pi) * 0.9), held = drv.(sin((ph * n).floor / n * 2pi) * 0.9);
				blend(dry, crush.(held), (b * 10).min(1)) },
			ref: { |ph| sin(ph * 2pi) * 0.9 }, refLabel: "clean", label: "drive, crush",
			readout: { |p| "drive % · crush %".format(pct.(p[\sdgdrive]), pct.(p[\sdgbits])) })
	],
	macros: [
		(name: "brightness", text: "tone and snap", targets: [[\sdgtone, 0.35], [\sdgsnap, 0.3]]),
		(name: "timbre", text: "drive and crush", targets: [[\sdgdrive, 0.35], [\sdgbits, 0.4]]),
		(name: "time", text: "body and noise lengths", targets: [[\sdgdecay, 0.4], [\sdgnoise, 0.4]]),
		(name: "movement", text: "source and unstable body", targets: [[\sdgcolor, 0.3], [\sdgindex, 0.5]])
	],
	cards: [
		(title: "source", coloured: true, knobs: [
			(key: \sdgcolor, label: "source", size: \big, spec: ControlSpec(0, 1, \lin, 0, 0.33), box: \pct, sub: "crackle → gendy")]),
		(title: "hit", knobs: [
			(key: \sdgpunch, label: "punch", spec: ControlSpec(0, 48, \lin, 0, 12, "st"), sub: "how far it falls"),
			(key: \sdgsnap, label: "snap", spec: ControlSpec(0, 1, \lin, 0, 0.6), box: \pct, sub: "body ↔ noise")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1, \lin, 0, 0.55), box: \pct, sub: "dark ↔ bright")]),
		(title: "dirt", knobs: [
			(key: \sdgdrive, label: "drive", spec: ControlSpec(0, 1, \lin, 0, 0.2), box: \pct, sub: "folds past 50"),
			(key: \sdgbits, label: "crush", spec: ControlSpec(0, 1, \lin, 0, 0.3), box: \pct, sub: "bits and rate")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(30, 2000, \exp, 0, 190, "Hz"), sub: "Hz and its note", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.01, 1.5, \exp, 0, 0.12, "s"), sub: "the body"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \sdgnoise, label: "noise", spec: ControlSpec(0.01, 1.5, \exp, 0, 0.18, "s"), sub: "its length"),
		(key: \sdgbend, label: "sweep", spec: ControlSpec(0.001, 1, \exp, 0, 0.03, "s"), sub: "follows decay"),
		(key: \sdgtail, label: "comb", spec: ControlSpec(0, 1, \lin, 0, 0.25), box: \pct, sub: "rings the noise"),
		(key: \sdgindex, label: "unstable", spec: ControlSpec(0, 1), box: \pct, sub: "source bends body")])
)
)
