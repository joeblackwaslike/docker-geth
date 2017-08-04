from invoke import task, call


DOCKER_COMPOSE_FILES = ['docker-compose.yaml']
DOCKER_COMPOSE_DEFAULTS = dict(
    up=['abort-on-container-exit', 'no-build'],
    down=['volumes']
)


def flags_to_arg_string(flags):
    return ' '.join(['--{}'.format(flag) for flag in flags])


@task(default=True)
def up(ctx):
    ctx.run('docker-compose {}'.format('up'))


@task(pre=[call(up, d=True)])
def launch(ctx):
    pass


@task
def down(ctx, flags=None):
    flags = DOCKER_COMPOSE_DEFAULTS['down'] + (flags or [])
    ctx.run('docker-compose {} {}'.format('down', flags_to_arg_string(flags)))


@task(pre=[down])
def rmf(ctx):
    ctx.run('docker-compose {} {}'.format('rm', '-v'))


@task
def build(ctx):
    ctx.run('docker-compose {} {}'.format('build', 'geth'))


@task
def rebuild(ctx):
    ctx.run('docker-compose {} {}'.format('build', '--no-cache'))


@task
def logs(ctx):
    ctx.run('docker-compose {} {}'.format('logs', '-f'))


@task
def shell(ctx, service='geth'):
    ctx.run('docker exec -ti {} {}'.format(service, 'bash'), pty=True)
