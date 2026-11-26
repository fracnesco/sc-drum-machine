// panels/sdgplastic.scd - what the plastic voice's window shows (SynthVoiceWindow).
// Its 16 controls: pitch, decay, level, tone and the three pitch moves on the front,
// the rest (fm, folding, the rub, the knock) in the fold.
(
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
var len = { |p| ((p[\sdgatk] + p[\sdgdecay]) * 1.05).clip(0.02, 2.2) };
// an Env segment of curve c, 0..1 in, 0..1 out
var seg = { |u, c| u = u.clip(0, 1); if(c.abs < 0.001) { u } { (1 - exp(c * u)) / (1 - exp(c)) } };
var perc = { |t, atk, dec, c| if(t < atk) { seg.(t / atk.max(1e-4), c) } { 1 - seg.((t - atk) / dec.max(1e-4), c) } };
// the def's pitch in semitones: the snap falling, the rise as it dies, the wobble, the slips
var journey = { |t, p|
	var atk = p[\sdgatk], dec = p[\sdgdecay], rate = p[\sdgcolor].linexp(0, 1, 6, 160);
	var snap = p[\sdgpunch].midiratio.blend(1, seg.(t / p[\sdgbend].max(0.001), -6)).ratiomidi;
	var rise = if(t < atk) { 0 } { 1.blend(p[\sdgrise].midiratio, seg.((t - atk) / dec.max(1e-4), 3)).ratiomidi };
	var wob = p[\sdgwobble] * 6 * sin(2pi * rate * t) * perc.(t, 0.002, atk + (dec * 0.8), -3);
	var slip = p[\sdgslip] * 1.0 * (sin(2pi * rate * t) > 0.31).binaryValue;
	snap + rise + wob + slip
};
(
	colour: \orchid, drum: true,
	hint: "rise makes a bubble, snap a latex crack, wobble rubber; the fold holds fm, folding, the rub and the knock",
	links: (sdgdecay: [\sdgbend]),
	panes: [
		(type: \pitch, w: 1.3, title: "the pitch's journey", len: len, func: journey,
			range: { |p| [p[\sdgwobble].neg * 6 - 2, (max(p[\sdgpunch], p[\sdgrise]) + (p[\sdgwobble] * 6) + 1).max(6)] }, zero: "pitch",
			readout: { |p| "% · from +% st · rises % st%".format(hz.(p[\sdgfreq]), p[\sdgpunch].round(0.1), p[\sdgrise].round(0.1),
				if(max(p[\sdgwobble], p[\sdgslip]) > 0.01) { " · wobbles at " ++ SynthVoicePanes.format(p[\sdgcolor].linexp(0, 1, 6, 160), "Hz") } { "" }) }),
		(type: \fm, w: 0.9, title: "fm, then folding", span: 12, ratio: { |p| p[\sdgratio] }, index: { |p| p[\sdgindex] },
			extra: { |p| "modulator x% · fold %".format(p[\sdgratio].round(0.01), pct.(p[\sdgwavefold])) }),
		(type: \env, w: 0.8, title: "rub or snap", len: len,
			curves: { |p| [(func: { |t| perc.(t, p[\sdgatk], p[\sdgdecay], -5) }, label: "level"),
				(func: { |t| (p[\sdgindex] / 10).sqrt * perc.(t, 0.0005, (p[\sdgdecay] * 0.6).max(0.004), -5) }, label: "fm")] },
			readout: { |p| "starts in % · rings %".format(SynthVoicePanes.format(p[\sdgatk], "s"), SynthVoicePanes.format(p[\sdgdecay], "s")) })
	],
	macros: [
		(name: "brightness", text: "filter and fm", targets: [[\sdgtone, 0.4], [\sdgindex, 0.3]]),
		(name: "timbre", text: "folding and resonance", targets: [[\sdgwavefold, 0.4], [\sdgq, 0.3]]),
		(name: "time", text: "decay, the snap follows", targets: [[\sdgdecay, 0.4], [\sdgbend, 0.4]]),
		(name: "movement", text: "wobble and rise", targets: [[\sdgwobble, 0.5], [\sdgrise, 0.3]])
	],
	cards: [
		(title: "pitch moves", knobs: [
			(key: \sdgrise, label: "rise", size: \big, spec: ControlSpec(0, 36, \lin, 0, 14, "st"), sub: "a bubble"),
			(key: \sdgpunch, label: "snap", spec: ControlSpec(0, 48, \lin, 0, 0, "st"), sub: "starts above"),
			(key: \sdgwobble, label: "wobble", spec: ControlSpec(0, 1), box: \pct, sub: "rubber")]),
		(title: "colour", knobs: [
			(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "dark ↔ bright"),
			(key: \sdgq, label: "res", spec: ControlSpec(0, 1), box: \pct, sub: "high, it pings")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(30, 9000, \exp, 0, 600, "Hz"), sub: "Hz and its note", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.005, 2, \exp, 0, 0.07, "s"), sub: "how long it rings"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \sdgatk, label: "attack", spec: ControlSpec(0.0005, 0.5, \exp, 0, 0.0005, "s"), sub: "rub ↔ snap"),
		(key: \sdgbend, label: "fall", spec: ControlSpec(0.001, 1, \exp, 0, 0.02, "s"), sub: "follows decay"),
		(key: \sdgslip, label: "squeak", spec: ControlSpec(0, 1), box: \pct, sub: "stick-slip"),
		(key: \sdgcolor, label: "speed", spec: ControlSpec(0, 1), box: \pct, sub: "wobble, slips"),
		(key: \sdgratio, label: "ratio", steps: [0.25, 0.5, 1, 1.41, 1.5, 1.73, 2, 2.76, 3, 3.5, 4, 5, 6, 7, 8], sub: "fm modulator"),
		(key: \sdgindex, label: "index", spec: ControlSpec(0, 10, \amp), floor: "off", sub: "fm amount"),
		(key: \sdgwavefold, label: "fold", spec: ControlSpec(0, 1), box: \pct, sub: "shine"),
		(key: \sdgclick, label: "knock", spec: ControlSpec(0, 1), box: \pct, sub: "hollow modes"),
		(key: \sdgdrive, label: "squash", spec: ControlSpec(0, 1), box: \pct, sub: "at the end")])
)
)
