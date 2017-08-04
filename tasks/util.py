from invoke import task


@task
def reset_data(ctx):
    ctx.run('rm -rf ~/.ethereum/*')
