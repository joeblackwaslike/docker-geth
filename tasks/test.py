from invoke import task


@task(default=True)
def run(ctx):
    for service in ctx.docker.services:
        print('testing {}'.format(service))
        ctx.run('tests/run {}'.format(service), pty=True)


@task
def edit(ctx):
    ctx.run('tests/edit {}'.format(ctx.docker.service), pty=True)
