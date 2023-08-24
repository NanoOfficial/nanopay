# frozen_string_literal: true

require 'mkmf'

$warnflags = ''

$CXXFLAGS << ' -std=c++11 -Wno-deprecated-register'
$CXXFLAGS.gsub!('-Wimplicit-int', '')
$CXXFLAGS.gsub!('-Wdeclaration-after-statement', '')
$CXXFLAGS.gsub!('-Wimplicit-function-declaration', '')

create_makefile 'score_suffix/score_suffix'
