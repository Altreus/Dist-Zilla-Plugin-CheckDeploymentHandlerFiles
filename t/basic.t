use v5.20;
use strict;
use warnings;
use Test::More;
use Test::DZil;
use File::pushd qw(pushd);
use Path::Tiny qw(path);

my $tzil = Builder->from_config(
    { dist_root => 'corpus/nodhfiles' },
    {
        add_files => {
            'source/dist.ini' => simple_ini(
                {
                    name => 'Test-App-Schema',
                },
                [ 'GatherDir' => { include_dotfiles => 1 } ],
                'FakeRelease',
                [
                    'CheckDeploymentHandlerFiles' => {
                        schema_module => 'Test::App::Schema'
                    }
                ]
            ),
        }
    }
);

my $err;
ok(
    !do {
        local $@ = '';
        eval { $tzil->build };
        $err = $@;
    },
    "build OK"
) or diag explain $err;

ok(
    do {
        local $@ = '';
        eval { $tzil->release };
        $err = $@;
    },
    "release threw exception"
);

like(
    $err,
    qr[\QTest/App/Schema/sql/PostgreSQL/upgrade/0-1\E],
    "Error cried about a missing 0 -> 1 upgrade step"
);

done_testing;
