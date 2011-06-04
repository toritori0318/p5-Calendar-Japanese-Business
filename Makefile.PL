use inc::Module::Install;
name 'Calendar-Japanese-Business';
all_from 'lib/Calendar/Japanese/Business.pm';

requires 'Time::Piece';
requires 'Calendar::Simple';
requires 'Calendar::Japanese::Holiday';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
WriteAll;

