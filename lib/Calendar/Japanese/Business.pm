package Calendar::Japanese::Business;

use strict;
use warnings;

our $VERSION = '0.01';

use Time::Piece;
use Calendar::Simple;
use Calendar::Japanese::Holiday;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw/year month day custom_holiday/);

my @calendar;

sub new {
    my $class = shift;
    my $args = ref $_[0] eq 'HASH' ? $_[0] : {@_};
    my $self = $class->SUPER::new($args);

    $self->year(localtime->year) unless $self->year;
    $self->month(localtime->mon) unless $self->month;
    @calendar = @{$self->init_calendar};
    $self;
}

sub init_calendar {
    my ($self) = @_;
    my ($year, $month) = ($self->year, $self->month);
    my @custom_holiday = ($self->custom_holiday) ? @{$self->custom_holiday} : ();

    my $active_day = 0;
    my $check_holiday = sub {
        my ($year, $month, $day, $week) = @_;
        if($week == 0 || $week == 6 || isHoliday($year, $month, $day) || grep /$day/, @custom_holiday){
            return 0;
        } else {
            return ++$active_day;
        }
    };

    my $cal = calendar($month, $year);

    my @ret_cal = ();
    for my $week (@$cal) {
        for (my $i = 0; $i < 7; $i++) {
            my $day = $week->[$i];
            if($day) {
                push @ret_cal, [$day, $check_holiday->($year, $month, $day, $i) ];
            }
        }
    }
    return \@ret_cal;
}

sub dump {
    return \@calendar;
}

sub _get_business {
    my ($self, $day, $business_day) = @_;
    $day          = -1 unless defined $day;
    $business_day = -1 unless defined $business_day;
    my @c = @calendar;
    for (@c) {
        return $_ if $_->[0] == $day || $_->[1] == $business_day;
    }
}
sub get_workday_from_day {
    my ($self, $day) = @_;
    return $self->_get_business($day)->[1];
}
sub get_date_from_businessday {
    my ($self, $day) = @_;
    $day = $self->_get_business(undef, $day)->[0];
    return $self->_get_timepiece($day);
}

sub _get_first_business {
    my ($self) = @_;
    my @c = @calendar;
    for (@c) {
        return $_ if $_->[1];
    }
}
sub get_first_date {
    my ($self) = @_;
    my $day = $self->_get_first_business->[0];
    return $self->_get_timepiece($day);
}
sub get_first_workday {
    my ($self) = @_;
    return $self->_get_first_business->[1];
}

sub _get_last_business {
    my ($self) = @_;
    my @c = @calendar;
    for (reverse @c) {
        return $_ if $_->[1];
    }
}
sub get_last_date {
    my ($self) = @_;
    my $day = $self->_get_last_business->[0];
    return $self->_get_timepiece($day);
}
sub get_last_workday {
    my ($self) = @_;
    return $self->_get_last_business->[1];
}

sub _get_timepiece {
    my ($self, $day) = @_;
    return Time::Piece->strptime($self->year.'-'.$self->month.'-'.$day, '%Y-%m-%d');
}

1;


1;
__END__

=head1 NAME

Calendar::Japanese::Business - 実働日（営業日）カレンダー

=head1 DESCRIPTION

休日／祝日を考慮した実働日を取得するモジュールです。

=head1 SYNOPSIS

  use Calendar::Japanese::Business;

  # default current year/month
  #my $c = Calendar::Japanese::Business->new;

  my $c = Calendar::Japanese::Business->new(
      {
          year           => 2011,
          month          => 5,
          custom_holiday => [2],
      }
  );

  # 16実働日 のTimpe::Pieceオブジェクトを取得
  $c->get_date_from_businessday(16); # => 2011/5/27

  # 2011/5/16 の実働日を取得
  $c->get_workday_from_day(16);        # => 7

  # 2011/5 の初回実働日のTime::Pieceオブジェクトを取得
  $c->get_first_date;    # => 2011/5/6

  # 2011/5 の初回実働日を取得（意味なし）
  $c->get_first_workday; # => 1

  # 2011/5 の最終実働日のTime::Pieceオブジェクトを取得
  $c->get_last_date;     # => 2011/5/31

  # 2011/5 の最終実働日を取得
  $c->get_last_workday;  # => 18

  # 2011/5 の実働日一覧
  print Dumper( $c->dump );

=head2 CONFIGURE

=over

=item year

実働日を取得したい年(デフォルト：現在の年)

=item month

実働日を取得したい月(デフォルト：現在の月)

=item custom_holiday

カスタムで休日に加えたい日を指定する。

=back

=head1 METHODS

=over

=item $c->get_date_from_businessday($day)

指定した実働日のTime::Pieceオブジェクトを取得します

=item $c->get_workday_from_day($day)

指定した日付の実働日を取得します

=item $c->get_first_date($day)

初回実働日のTime::Pieceオブジェクトを取得します

=item $c->get_first_workday($day)

初回実働日を取得します（必ず１が戻るので意味なし）

=item $c->get_last_date($day)

最終実働日のTime::Pieceオブジェクトを取得します

=item $c->get_last_workday($day)

最終実働日を取得します

=item $c->dump

年月の実働日一覧を取得します

=back

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

torii, E<lt>torii@localE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by torii

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
