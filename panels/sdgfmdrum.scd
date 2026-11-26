// panels/sdgfmdrum.scd - what the FM drum's window shows (SynthVoiceWindow). The ratio steps
// through a list (\sdgratio) and a fine knob (\ui_fine, in the fold) moves off it: derive sends
// their sum. The modulator's decay (sdgcolor) is a share of the body's: the pane shows it in ms.
(
var seg = { |t, len, c| if(t >= len) { 1 } { (1 - exp(c * t / len.max(0.0001))) / (1 - exp(c)) } };
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
var ratios = [0.5, 1, 1.41, 2, 2.37, 2.76, 3, 3.5, 4, 5, 6, 8, 12, 16];
var ratio = { |p| (p[\sdgratio] ? 1) + (p[\ui_fine] ? 0) };
var modTime = { |p| p[\sdgdecay] * p[\sdgcolor].clip(0, 1).linexp(0, 1, 0.04, 1.2) };
var modEnd = { |p| (p[\sdgcolor].clip(0, 1) - 0.5).max(0) * 1.2 };
var len = { |p| max(p[\sdgdecay], ((p[\sdgcount] ? 1).round - 1) * 0.011 + p[\sdgnoise]) * 1.1 };
(
	colour: \aqua, drum: true,
	hint: "ratio - steps through 1, 2, 3... and the knock ratios 1.41, 2.37, 2.76, 3.5; fm time is how long the index lasts, a share of the decay",
	links: (sdgdecay: [\sdgbend, \sdgnoise]),
	derive: { |v| (sdgratio: (v[\sdgratio] ? 1) + (v[\ui_fine] ? 0)) },
	split: { |v| var r = v[\sdgratio] ? 1, near = ratios[ratios.indexIn(r)];
		v[\sdgratio] = near; v[\ui_fine] = r - near },
	panes: [
		(type: \pitch, w: 0.8, title: "the drop", len: { |p| (p[\sdgbend] * 2.5).clip(0.05, 1.5) }, func: { |t, p| p[\sdgpunch] * exp(t.neg * 5 / p[\sdgbend].max(0.001)) },
			range: { |p| [-2, (p[\sdgpunch] * 1.15).max(4)] }, zero: "lands",
			readout: { |p| "% st in % · %".format(p[\sdgpunch].round(0.1), SynthVoicePanes.format(p[\sdgbend], "s"), hz.(p[\sdgfreq])) }),
		(type: \fm, w: 1.1, title: "carrier and modulator", carrier: 1, ratio: ratio, index: { |p| p[\sdgindex] }, reflect: true,
			readout: { |p| "x% · index %".format(ratio.(p).round(0.01), p[\sdgindex].round(0.1)) },
			extra: { |p| "feedback % · metal %".format(pct.(p[\sdgfb]), pct.(p[\sdgmetal])) }),
		(type: \env, w: 1, title: "body, fm and noise", len: len,
			curves: { |p| var nstart = ((p[\sdgcount] ? 1).round - 1) * 0.011, snap = p[\sdgsnap].clip(0, 1);
				[(func: { |t| (1 - snap).sqrt * (1 - seg.(t, p[\sdgdecay], -4.5)) }, label: "body"),
				(func: { |t| var e = modEnd.(p); 1 + ((e - 1) * seg.(t, modTime.(p), -4)) }, label: "fm index"),
				(func: { |t| if(t < nstart) { 0 } { snap.sqrt * (1 - seg.(t - nstart, p[\sdgnoise], -5)) } }, label: "noise", colour: \dim)] },
			readout: { |p| "fm % · body %".format(SynthVoicePanes.format(modTime.(p), "s"), SynthVoicePanes.format(p[\sdgdecay], "s")) })
	],
	macros: [
		(name: "brightness", text: "index and noise tone", targets: [[\sdgindex, 0.35], [\sdgtone, 0.3]]),
		(name: "timbre", text: "metal and feedback", targets: [[\sdgmetal, 0.4], [\sdgfb, 0.3]]),
		(name: "time", text: "decay and fm time", targets: [[\sdgdecay, 0.4], [\sdgcolor, 0.3]]),
		(name: "movement", text: "how far and slow it falls", targets: [[\sdgpunch, 0.35], [\sdgbend, 0.5]])
	],
	cards: [
		(title: "fm", coloured: true, knobs: [
			(key: \sdgratio, label: "ratio", size: \big, steps: ratios, sub: "a list"),
			(key: \sdgindex, label: "index", size: \big, spec: ControlSpec(0.05, 25, \exp, 0, 2.5), floor: "off", sub: "at the strike"),
			(key: \sdgcolor, label: "fm time", spec: ControlSpec(0, 1), box: \pct, sub: "share of decay")]),
		(title: "hit", knobs: [
			(key: \sdgpunch, label: "punch", spec: ControlSpec(0, 48, \lin, 0, 30, "st"), sub: "how far it falls"),
			(key: \sdgsnap, label: "snap", spec: ControlSpec(0, 1), box: \pct, sub: "body ↔ noise")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "of the noise")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(20, 5000, \exp, 0, 48, "Hz"), sub: "Hz and its note", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.02, 3, \exp, 0, 0.5, "s"), sub: "the body"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \ui_fine, label: "fine", spec: ControlSpec(-0.5, 0.5, \lin, 0, 0), sub: "off the list", text: "moves the ratio off the list, ±0.5"),
		(key: \sdgfb, label: "feedback", spec: ControlSpec(0, 1), box: \pct, sub: "noise from 90 %"),
		(key: \sdgmetal, label: "metal", spec: ControlSpec(0, 1), box: \pct, sub: "a 2nd modulator"),
		(key: \sdgbend, label: "sweep", spec: ControlSpec(0.001, 1, \exp, 0, 0.035, "s"), sub: "follows decay"),
		(key: \sdgnoise, label: "noise", spec: ControlSpec(0.01, 2, \exp, 0, 0.15, "s"), sub: "follows decay"),
		(key: \sdgcount, label: "bursts", steps: [1, 2, 3, 4, 5, 6, 7, 8], sub: "a clap"),
		(key: \sdgclick, label: "click", spec: ControlSpec(0, 1), box: \pct, sub: "the strike"),
		(key: \sdgdrive, label: "drive", spec: ControlSpec(0, 1), box: \pct)])
)
)
