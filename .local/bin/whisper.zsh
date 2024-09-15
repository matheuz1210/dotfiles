#!/bin/zsh -e
zmodload zsh/mathfunc

# additional args to whisper
: ${WHISPERARGS:=""}

# threads used
: ${WHISPERTHREADS:=$(nproc)}

# model used
: ${WHISPERMODEL:=small}

# temporary directory
: ${WHISPERTMP:=tmp}

# output directory
: ${WHISPEROUT:=out}

[ -d $WHISPERTMP ] && rm -r $WHISPERTMP
mkdir -p $WHISPERTMP $WHISPEROUT

for file ( $@ ) {
	export NAME=${file:t:r} && tmpfile=$WHISPERTMP/$NAME
    if [[ -f $WHISPEROUT/$NAME.json ]] { continue }
	ffmpeg -i $file -ar 16000 -ac 1 -c:a pcm_s16le -f wav $tmpfile

	whisperx \
		--verbose True --print_progress True \
		--threads $WHISPERTHREADS \
		--output_dir $WHISPERTMP \
		--model $WHISPERMODEL \
		${=WHISPERARGS} $tmpfile

	cp $tmpfile.srt $WHISPEROUT
	jq -f /dev/stdin $tmpfile.json > $WHISPEROUT/$NAME.json  <<"JQEXPR"
.segments[] | {
		speaker: $ENV.NAME,
		text,

		timestamp: .start
}
JQEXPR
}

python - =(jq -s . $WHISPEROUT/*.json) $WHISPEROUT/out.html <<"PYEXPR"
import sys
import base64
import typing
import html
from decimal import Decimal
import json

colors: dict[str, str] = {
    "kiwi": "#30faa7",
    "alex": "#fa8072",
    "felix": "#3498db",
    "mat": "#00a7a7",
    "bot": "#8beded",
}


class Segments(typing.TypedDict):
    speaker: str
    text: str
    timestamp: Decimal


with open(sys.argv[1], "rt") as j:
    segments: list[Segments] = json.load(j, parse_float=Decimal)
segments.sort(key=lambda x: x["timestamp"])


lrc = ""
html_body = ""
for segment in segments:
    mins, secs = divmod(int(segment["timestamp"]), 60)
    csecs = str(segment["timestamp"].quantize(Decimal("0.01")))[-2:]

    lrc_timestamp = f"[{mins:02}:{secs:02}.{csecs}]"
    hrs, mins = divmod(mins, 60)
    html_timestamp = f"[{hrs:02}:{mins:02}:{secs:02}.{csecs}]"

    lrc += f"{lrc_timestamp} {segment['speaker']}: {segment['text']}\n"
    html_body += f"<p class='{segment['speaker']}'>\n\t{html.escape(f'{html_timestamp} {segment["speaker"]}: {segment["text"]}')}\n</p>\n"

lrc_url = html.escape(
    "data:text/plain;charset=UTF-8;base64,"
    + str(base64.b64encode(bytes(lrc, encoding="utf-8")), encoding="utf-8")
)

css = ""
for speaker, color in colors.items():
    css += f'.{speaker} {{ color: {color}; }}\n'

with open(sys.argv[2], "wt") as out:
    out.write(
        f"""<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <style>
""")
    out.write(css)
    out.write(
        """</style>
</head>

<body>"""
    )
    out.write(f'<a download="out.lrc" href="{lrc_url}">Download LRC file</a>')
    out.write(html_body)
    out.write("</body></html>")
PYEXPR
