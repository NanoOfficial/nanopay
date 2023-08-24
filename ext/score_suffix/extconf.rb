require 'mkmf'

$warnflags = ''
$CXXFLAGS << '-std=c++11 -Wno-deprecated-register'

create_makefile 'score_suffx/score_suffix'