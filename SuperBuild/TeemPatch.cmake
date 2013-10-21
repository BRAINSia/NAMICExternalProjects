file(READ ${SANE_FILE} code)
string(REPLACE "static int _airSanity=0;"
  "static int _airSanity=1;" code "${code}")
file(WRITE ${SANE_FILE} "${code}")
