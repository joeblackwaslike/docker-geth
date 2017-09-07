from invoke import task


@task(default=True)
def attach(ctx):
    ctx.run('docker exec -ti swarm geth attach ipc:///root/.ethereum/bzzd.ipc',
            pty=True)
