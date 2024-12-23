setStreamOutMode -specifyViaName default -SEvianames false -virtualConnection false -uniquifyCellNamesPrefix false -snapToMGrid false -textSize 1 -version 3

streamOut ../post_layout/CHIP.gds -mapFile /usr/cadtool/GPDK45/gpdk045_v_6_0/soce/streamOut.map \
      -merge { /usr/cadtool/GPDK45/gsclib045_svt_v4.4/gsclib045/gds/gsclib045.gds } \
      -units 2000 -mode ALL -uniquifyCellNames

