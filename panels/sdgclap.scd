// panels/sdgclap.scd - what the clap's window shows (SynthVoiceWindow).
(
var fall = { |decay| { |t| exp(t.neg * 6.9 / decay.max(0.001)) } };
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var gap = { |p| p[\sdgcolor].linlin(0, 1, 0.004, 0.024) };
var count = { |p| p[\sdgcount].round.clip(1, 8).asInteger };
// where the bursts fall: each gap a little off, more when looser (a fixed picture of the random)
var starts = { |p| var g = gap.(p); (0 .. 7).collect { |i| g * (1 + (sin((i + 1) * 5.1) * p[\sdgcolor] * 0.35)) }.integrate.addFirst(0) };
var last = { |p| starts.(p)[count.(p) - 1] };
var taillen = { |p| p[\sdgtail].linlin(0, 1, 0.15, 1.3) };
(
	colour: \gold, drum: true,
	hint: "tune - the band's centre, 300 Hz to 4 kHz; the room follows the decay",
	links: (sdgdecay: [\sdgtail]),
	panes: [
		(type: \hits, w: 1.1, title: "the hands", len: { |p| last.(p) + p[\sdgdecay] + 0.03 },
			list: { |p| var n = count.(p), st = starts.(p);
				(n - 1).collect { |i| (t: st[i], level: 0.7, len: 0.009) }
				++ [(t: st[n - 1], level: 1, len: p[\sdgdecay])] },
			readout: { |p| "% · % apart · the last %".format(if(count.(p) == 1) { "1 hand" } { count.(p).asString ++ " hands" },
				SynthVoicePanes.format(gap.(p), "s"), SynthVoicePanes.format(p[\sdgdecay], "s")) }),
		(type: \filter, mode: \bp, w: 0.9, title: "the band", cut: { |p| p[\sdgfreq] }, q: { |p| p[\sdgq] },
			readout: { |p| "noise at % · narrow %".format(SynthVoicePanes.format(p[\sdgfreq], "Hz"), pct.(p[\sdgq])) }),
		(type: \env, title: "clap and room", len: { |p| max(last.(p) + p[\sdgdecay], taillen.(p) + 0.012) * 1.05 },
			curves: { |p| [
				(func: { |t| var t0 = last.(p); if(t < t0) { 0 } { fall.(p[\sdgdecay]).(t - t0) } }, label: "last hand"),
				(func: { |t| p[\sdgtail] * 0.6 * if(t < 0.012) { t / 0.012 } { fall.(taillen.(p)).(t - 0.012) } }, label: "room")] },
			readout: { |p| if(p[\sdgtail] < 0.01) { "no room" } { "room % to -60 dB".format(SynthVoicePanes.format(taillen.(p), "s")) } })
	],
	macros: [
		(name: "brightness", text: "air and a higher band", targets: [[\sdgtone, 0.5], [\sdgfreq, 0.25]]),
		(name: "timbre", text: "more hands, looser", targets: [[\sdgcount, 0.35], [\sdgcolor, 0.4]]),
		(name: "time", text: "decay, the room follows", targets: [[\sdgdecay, 0.4], [\sdgtail, 0.4]]),
		(name: "movement", text: "loose hands spread out", targets: [[\sdgcolor, 0.35], [\sdgspread, 0.5]])
	],
	cards: [
		(title: "hands", knobs: [
			(key: \sdgcount, label: "hands", steps: [1, 2, 3, 4, 5, 6, 7, 8], sub: "the bursts"),
			(key: \sdgcolor, label: "loose", spec: ControlSpec(0, 1), box: \pct, sub: "4 to 24 ms apart")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "dark ↔ bright")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(300, 4000, \exp, 0, 1100, "Hz"), sub: "the band", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.01, 1, \exp, 0, 0.12, "s"), sub: "the last hand"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \sdgtail, label: "room", spec: ControlSpec(0, 1), box: \pct, sub: "follows decay"),
		(key: \sdgq, label: "narrow", spec: ControlSpec(0, 1), box: \pct, sub: "the band"),
		(key: \sdgspread, label: "spread", spec: ControlSpec(0, 1), box: \pct, sub: "stereo")])
)
)
