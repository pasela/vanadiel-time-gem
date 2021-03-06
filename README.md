# vanadiel-time

* [Homepage](https://github.com/pasela/vanadiel-time-gem)
* [Issues](https://github.com/pasela/vanadiel-time-gem/issues)
* [Documentation](http://rubydoc.info/gems/vanadiel-time/frames)
* [Email](mailto:paselan at gmail.com)

## Description

A library for dealing with Vana'diel time from Final Fantasy XI.
Converting between realtime and Vana'diel time, and so on.

## Examples

    require 'vanadiel/time'

    p Vanadiel::Time.now  #=> 1156-09-01 10:31:27
    p Vanadiel::Time.new(1156, 2, 4, 10, 15, 30) #=> 1156-02-04 10:15:30

Another example:

    require 'vanadiel/time'

    et = Time.now
    vt = Vanadiel::Time.at(et)

    puts "Earth    : %s" % et.strftime("%Y-%m-%d %H:%M:%S %A")
    puts "Vana'diel: %s" % vt.strftime("%Y-%m-%d %H:%M:%S %A")
    puts "           %s %s (%d%%)" % [Vanadiel::Moon::MOONNAMES_JA[vt.moon_age],
                                      Vanadiel::Moon::MOONNAMES[vt.moon_age],
                                      vt.moon_percent]

output:

    Earth    : 2012-09-02 02:58:43 Sunday
    Vana'diel: 1156-08-19 02:28:06 Iceday
               二十日余月 Waning Crescent (38%)

## Install

    $ gem install vanadiel-time

## Copyright

Copyright (c) 2018 Yuki, a.k.a. Pasela

See [LICENSE](/LICENSE.txt) for details.
