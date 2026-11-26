// panels/sdgmodal.scd - what the modal drum's window shows (SynthVoiceWindow). The mode tables
// are the def's, so the partials pane draws what it rings: ratios, strengths, ring times.
(
var tables = [
	[1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
	[1, 1.593, 2.136, 2.295, 2.653, 2.917, 3.155, 3.5, 3.598, 3.647],
	[1, 3.93, 9.36, 16.8, 2.53, 6.1, 12.4, 24.9, 4.9, 34],
	[1, 2.756, 5.404, 8.933, 13.344, 18.637, 24.814, 31.873, 39.81, 48.63],
	[1, 2.081, 3.414, 3.893, 4.995, 5.954, 6.819, 8.28, 8.722, 8.882]
];
var levels = [
	[1, 0.8, 0.6, 0.45, 0.35, 0.25, 0.18, 0.12, 0.08, 0.05],
	[1, 0.9, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.5],
	[1, 0.45, 0.2, 0.08, 0.12, 0.08, 0.05, 0.03, 0.06, 0.02],
	[1, 0.7, 0.5, 0.35, 0.25, 0.18, 0.12, 0.08, 0.06, 0.04],
	[1, 0.9, 0.8, 0.7, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35]
];
var damps = [0.8, 1.0, 1.3, 0.55, 0.4];
var bessel = [
	[1.00, 0.91, 0.67, 0.34, 0.13], [0.00, 0.43, 0.58, 0.38, 0.16], [0.00, 0.18, 0.46, 0.40, 0.18],
	[1.00, 0.58, 0.17, 0.38, 0.19], [0.00, 0.07, 0.34, 0.40, 0.19], [0.00, 0.58, 0.13, 0.35, 0.20],
	[0.00, 0.03, 0.25, 0.39, 0.20], [0.00, 0.38, 0.31, 0.29, 0.21], [1.00, 0.13, 0.36, 0.26, 0.22],
	[0.00, 0.01, 0.18, 0.37, 0.21]
];
// LinSelectX over a list at x
var sel = { |list, x| var i = x.clip(0, list.size - 1), lo = i.floor.asInteger.min(list.size - 1); blend(list[lo], list[(lo + 1).min(list.size - 1)], i - lo) };
// the ten modes as the def makes them: ratio, strength (normalised), ring time
var modes = { |p|
	var m = p[\sdgmetal].clip(0, 1) * 4, pos = p[\sdgcolor].clip(0, 1), skin = (1 - (m - 1).abs).max(0);
	var damp = sel.(damps, m), f = p[\sdgfreq];
	var ms = 10.collect { |k|
		var r = sel.(tables.collect(_[k]), m);
		var plain = 0.15 + (0.85 * sin(pi * (k + 1) * (0.5 - (pos * 0.45))).abs);
		var w = plain + ((sel.(bessel[k], pos * 4).max(0.03) - plain) * skin);
		(r: r, amp: sel.(levels.collect(_[k]), m) * w * ((f * r) < 18000).binaryValue, ring: p[\sdgdecay] * (r ** damp.neg))
	};
	var top = ms.collect(_[\amp]).maxItem.max(0.001);
	ms.do { |e| e[\amp] = e[\amp] / top };
	ms
};
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
(
	colour: \aqua, drum: true,
	hint: "material - tuned, skin, marimba bar, free bar, plate: the modes' ratios morph from one to the next",
	links: (sdgdecay: [\sdgbend]),
	panes: [
		(type: \partials, w: 1.2, title: "ten modes", lo: 40, list: { |p| var mallet = p[\sdgtone].clip(0, 1).linexp(0, 1, 1, 25);
			modes.(p).collect { |e, i| (hz: p[\sdgfreq] * e[\r], level: e[\amp] * (1 / (1 + ((e[\r] / mallet) ** 2))).sqrt.max(0.05),
				fade: (e[\ring] / p[\sdgdecay]).clip(0, 1).linlin(0, 1, 0.45, 1), colour: if(i == 0) { \wave } { \id }, label: if(i == 0) { "lowest" }) } },
			readout: { |p| "% · rings % · faint = dies sooner".format(hz.(p[\sdgfreq]), SynthVoicePanes.format(p[\sdgdecay], "s")) }),
		(type: \stops, w: 0.9, title: "the material", names: ["tuned", "skin", "marimba", "glass", "plate"], pos: { |p| p[\sdgmetal] },
			glyph: { |u, pos, p| var t = u * 0.06; modes.(p).collect { |e| e[\amp] * sin(2pi * 110 * e[\r] * t) * exp(t.neg * 6.9 / (e[\ring] * 0.15).max(0.005)) }.sum * 0.45 },
			readout: { |p| "hit % · % mallet".format(if(p[\sdgcolor] < 0.5) { "near the centre" } { "near the edge" }, if(p[\sdgtone] < 0.5) { "soft" } { "hard" }) }),
		(type: \pitch, w: 0.7, title: "the skin stretches", len: { |p| (p[\sdgbend] * 2.5).clip(0.05, 1.5) }, func: { |t, p| p[\sdgpunch] * exp(t.neg * 5 / p[\sdgbend].max(0.001)) },
			range: { |p| [-1, (p[\sdgpunch] * 1.15).max(3)] }, zero: "lands",
			readout: { |p| "% st in %".format(p[\sdgpunch].round(0.1), SynthVoicePanes.format(p[\sdgbend], "s")) })
	],
	macros: [
		(name: "brightness", text: "mallet and where", targets: [[\sdgtone, 0.4], [\sdgcolor, 0.3]]),
		(name: "timbre", text: "material and snare wires", targets: [[\sdgmetal, 0.3], [\sdgsnap, 0.3]]),
		(name: "time", text: "decay, the settle follows", targets: [[\sdgdecay, 0.45]]),
		(name: "movement", text: "the skin's bend", targets: [[\sdgpunch, 0.4], [\sdgbend, 0.4]])
	],
	cards: [
		(title: "object", coloured: true, knobs: [
			(key: \sdgmetal, label: "material", size: \big, spec: ControlSpec(0, 1, \lin, 0, 0.25), box: \pct, sub: "skin → plate")]),
		(title: "strike", knobs: [
			(key: \sdgcolor, label: "where", spec: ControlSpec(0, 1, \lin, 0, 0.4), box: \pct, sub: "centre ↔ edge"),
			(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "felt ↔ stick")]),
		(title: "skin", knobs: [
			(key: \sdgpunch, label: "punch", spec: ControlSpec(0, 24, \lin, 0, 2, "st"), sub: "it starts up"),
			(key: \sdgbend, label: "settle", spec: ControlSpec(0.001, 1, \exp, 0, 0.06, "s"), sub: "follows decay"),
			(key: \sdgsnap, label: "snares", spec: ControlSpec(0, 1), box: \pct, sub: "wires rattle")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(30, 4000, \exp, 0, 110, "Hz"), sub: "Hz and its note", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.05, 6, \exp, 0, 0.6, "s"), sub: "lowest mode"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	]
)
)
