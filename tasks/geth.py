from invoke import task


@task(default=True)
def attach(ctx):
    ctx.run('docker exec -ti geth geth attach', pty=True)


@task
def removedb(ctx):
    ctx.run('docker exec geth geth removedb')


@task
def start_mine(ctx):
    ctx.run('docker-compose run -e "GETH_MINE=true" -d geth-wrap geth')


@task
def list_accounts(ctx):
    ctx.run('docker exec geth geth account list')
