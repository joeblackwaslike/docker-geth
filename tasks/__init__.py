import os

from invoke import Collection, task

from . import test, dc, kube, geth, util, swarm


COLLECTIONS = [test, dc, kube, geth, util, swarm]

ns = Collection()
for c in COLLECTIONS:
    ns.add_collection(c)

ns.configure(dict(
    project='geth',
    repo='docker-geth',
    pwd=os.getcwd(),
    docker=dict(
        user=os.getenv('DOCKER_USER'),
        org=os.getenv('DOCKER_ORG',
                      os.getenv('DOCKER_USER', 'joeblackwaslike')),
        tag='%s/%s:latest' % (
            os.getenv('DOCKER_ORG',
            os.getenv('DOCKER_USER', 'joeblackwaslike')), 'couchdb'
        ),
        service='geth',
        shell='bash'
    ),
    kube=dict(
        environment='testing'
    )
))

@task
def templates(ctx):
    files = ' '.join(glob.iglob('templates/**.j2', recursive=True))
    ctx.run('tmpld --strict --data templates/vars.yaml {}'.format(files))

ns.add_task(templates)
