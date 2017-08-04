from invoke import task


@task(default=True)
def attach(ctx):
    ctx.run('docker exec -ti geth geth attach', pty=True)


@task
def removedb(ctx):
    ctx.run('echo "y\n" | docker-compose run --rm --no-deps geth geth removedb')


@task
def start_mine(ctx):
    ctx.run('docker-compose run -e "GETH_MINE=true" -d geth')


@task
def create_account(ctx):
    ctx.run('docker-compose run --rm --no-deps geth geth account new')


@task
def list_accounts(ctx):
    ctx.run('docker exec geth geth account list')
