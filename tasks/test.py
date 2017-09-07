from invoke import task


@task(default=True)
def run(ctx):
    ctx.run('tests/run {}'.format(ctx.docker.service), pty=True)


@task
def edit(ctx):
    ctx.run('tests/edit {}'.format(ctx.docker.service), pty=True)
