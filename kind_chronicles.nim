import chronicles, terminal, tables, strutils

var TOPIC_COLORS = {"prestart": fgWhite, "index": fgYellow, "gdb": fgRed, "debugger": fgGreen, "plugin": fgBlue, "preload": fgMagenta, "move": fgCyan, "python": fgWhite}.toTable()

type KindRecord*[Output; colors: static[ColorScheme]] = object
  output*: Output
  color*: ForegroundColor
  path*: string

# TODO: export in log_output
template fgColor(record, color, brightness) =
  when record.colors == AnsiColors:
    append(record.output, ansiForegroundColorCode(color, brightness))
  elif record.colors == NativeColors:
    setForegroundColor(getOutputStream(record.output), color, brightness)

template resetColors(record) =
  when record.colors == AnsiColors:
    append(record.output, ansiResetCode)
  elif record.colors == NativeColors:
    resetAttributes(getOutputStream(record.output))

template shortName(lvl: LogLevel): string =
  # Same-length strings make for nice alignment
  case lvl
  of TRACE: "TRC"
  of DEBUG: "DBG"
  of INFO:  "INF"
  of NOTICE:"NOT"
  of WARN:  "WRN"
  of ERROR: "ERR"
  of FATAL: "FAT"
  of NONE:  "   "

# end

template initLogRecord*(r: var KindRecord, lvl: LogLevel, topics: string, raw: string) =
  if TOPIC_COLORS.hasKey(topics):
    r.color = TOPIC_COLORS[topics]
  else:
    r.color = fgBlue
  fgColor(r, r.color, false)
  r.output.append shortName(lvl) , " ", topics.align(20, ' ')
  r.output.append " ", raw.align(80, ' ')
  resetColors(r)
  

template setProperty*(r: var KindRecord, key: string, val: auto) =
  if key != "tid" and key != "file":
    r.output.append " ", key, " ", $val
  elif key == "file":
    r.path = ($val).rsplit("/", 1)[1]

template setFirstProperty*(r: var KindRecord, key: string, val: auto) =
  fgColor(r, r.color, false)
  r.setProperty key, val

template flushRecord*(r: var KindRecord) =
  r.output.append " " & r.path.align(20, ' ')
  resetColors(r)
  r.output.append "\n"
  r.output.flushOutput

export chronicles
