// panels/sdgping.scd - what the ping's window shows (SynthVoiceWindow). The FM ratio steps
// through a list (\sdgratio) and a fine knob (\ui_fine, in the fold) moves off it: derive sends
// their sum. The FM's own decay (sdgfmtime) is a share of the ring's: the pane shows it in ms.
(
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
var ratios = [0.25, 0.5, 1, 1.41, 2, 2.76, 3, 3.5, 4, 5, 6, 8];
var ratio = { |p| (p[\sdgratio] ? 1.41) + (p[\ui_fine] ? 0) };
(
	colour: \aqua, drum: true,
	hint: "index - FM on the main resonator, off at the bottom; ratio steps through whole numbers and 1.41, 2.76, 3.5",
	links: (sdgdecay: [\sdgbend]),
	derive: { |v| (sdgratio: ((v[\sdgratio] ? 1.41) + (v[\ui_fine] ? 0)).clip(0.25, 8)) },
	split: { |v| var r = v[\sdgratio] ? 1.41, near = ratios[ratios.indexIn(r)];
		v[\sdgratio] = near; v[\ui_fine] = r - near },
	panes: [
		(type: \partials, w: 1.1, title: "three resonators", lo: 40, list: { |p|
			var m = p[\sdgmetal].clip(0, 1), tone = p[\sdgtone].clip(0, 1);
			var rs = [1, 2 * (1.38 ** m), 3 * (1.8 ** m)], amps = [1, 0.25 + (tone * 0.45), 0.08 + (tone * 0.35)];
			rs.collect { |r, i| (hz: p[\sdgfreq] * r, level: amps[i], fade: [1, 0.8, 0.6][i],
				label: if(i == 0) { "the ping" } { "x" ++ r.round(0.01) }, colour: if(i == 0) { \wave } { \id }) } },
			readout: { |p| "% · rings %".format(hz.(p[\sdgfreq]), SynthVoicePanes.format(p[\sdgdecay], "s")) }),
		(type: \pitch, w: 0.9, title: "sweep", len: { |p| (p[\sdgbend] * 2).clip(0.02, 1.5) },
			func: { |t, p| p[\sdgpunch] * (1 - (t / p[\sdgbend].max(0.001)).min(1)) },
			range: { |p| [min(-2, p[\sdgpunch] * 1.1), max(p[\sdgpunch] * 1.1, 4)] }, zero: "lands",
			readout: { |p| "% st in %".format((if(p[\sdgpunch] > 0) { "+" } { "" }) ++ p[\sdgpunch].round(0.1), SynthVoicePanes.format(p[\sdgbend], "s")) }),
		(type: \fm, w: 0.9, title: "fm on the ping", span: 10, reflect: true, carrier: 1, ratio: ratio, index: { |p| p[\sdgindex] },
			readout: { |p| if(p[\sdgindex] < 0.06) { "off - a pure ping" } { "x% · index %".format(ratio.(p).round(0.01), p[\sdgindex].round(0.1)) } },
			extra: { |p| "bright for % of %".format(SynthVoicePanes.format(p[\sdgdecay] * p[\sdgfmtime], "s"), SynthVoicePanes.format(p[\sdgdecay], "s")) })
	],
	macros: [
		(name: "brightness", text: "hard mallet and fm", targets: [[\sdgtone, 0.35], [\sdgindex, 0.3]]),
		(name: "timbre", text: "metal and ratio fine", targets: [[\sdgmetal, 0.4], [\ui_fine, 0.2]]),
		(name: "time", text: "ring and fm time", targets: [[\sdgdecay, 0.45], [\sdgfmtime, 0.3]]),
		(name: "movement", text: "sweep and rattle", targets: [[\sdgpunch, 0.3], [\sdgcolor, 0.4]])
	],
	cards: [
		(title: "resonators", coloured: true, knobs: [
			(key: \sdgmetal, label: "metal", size: \big, spec: ControlSpec(0, 1, \lin, 0, 0.15), box: \pct, sub: "harmonic ↔ bar")]),
		(title: "fm", knobs: [
			(key: \sdgindex, label: "index", spec: ControlSpec(0.05, 8, \exp, 0, 0.05), floor: "off", sub: "on the ping"),
			(key: \sdgratio, label: "ratio", steps: ratios, sub: "a list"),
			(key: \sdgfmtime, label: "fm time", spec: ControlSpec(0.05, 2, \exp, 0, 0.5), box: \pct, sub: "share of decay")]),
		(title: "sweep", knobs: [
			(key: \sdgpunch, label: "from", spec: ControlSpec(-24, 48, \lin, 0, 12, "st"), sub: "below: a droplet"),
			(key: \sdgbend, label: "time", spec: ControlSpec(0.001, 1, \exp, 0, 0.025, "s"), sub: "follows decay")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1, \lin, 0, 0.8), box: \pct, sub: "felt ↔ click")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(40, 12000, \exp, 0, 1200, "Hz"), sub: "Hz and its note", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.005, 2, \exp, 0, 0.09, "s"), sub: "the ring"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \ui_fine, label: "fine", spec: ControlSpec(-0.5, 0.5, \lin, 0, 0), sub: "off the list", text: "moves the ratio off the list, ±0.5"),
		(key: \sdgcolor, label: "rattle", spec: ControlSpec(0, 1), box: \pct, sub: "hit again"),
		(key: \sdgclick, label: "tick", spec: ControlSpec(0, 1), box: \pct, sub: "noise on top")])
)
)
