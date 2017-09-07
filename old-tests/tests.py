import unittest

import testdocker
from testdocker import (
    ContainerTestMixinBase,
    ContainerTestMixin,
    CurlCommand
)


class TestGeth(ContainerTestMixin, unittest.TestCase):
    """Test geth container."""

    name = 'geth'
    tear_down = False
    test_patterns = [
        r"Initialised chain configuration",
        r"Disk storage enabled for ethash caches",
        r'Disk storage enabled for ethash DAGs',
        r'UDP listener up',
        r"RLPx listener up",
        r'HTTP endpoint opened: http://0.0.0.0:8545',
        'IPC endpoint opened: /root/.ethereum/geth.ipc',
    ]
    test_tcp_ports = [30303, 8545]
    test_udp_ports = [30303]
    test_http_uris = ['http://localhost:8545']


class TestSwarm(ContainerTestMixin, unittest.TestCase):
    """Test swarm container."""

    name = 'swarm'
    tear_down = True
    test_patterns = [
        r"using Testnet ENS contract address",
        r"UDP listener up",
        r"RLPx listener up",
        'Swarm network started on bzz address',
        'Swarm http proxy started on 0.0.0.0:8500',
        'IPC endpoint opened: /root/.ethereum/bzzd.ipc',
    ]
    test_tcp_ports = [30399, 8500]
    test_udp_ports = [30399]

    bzz_hashes = []

    def test_file_upload(self):
        """Assert file is uploaded into swarm"""
        cmd = CurlCommand('http://localhost:8500/bzz:',
                          method='POST',
                          file='tests/fixtures/upload-test-file.txt')
        exit_code, output = self.container.exec(cmd)
        self.assertEqual(exit_code, 0)
        self.assertRegex(output, r'[0-9a-f]{64}')
        self.bzz_hashes.append(output)

    def test_file_retrieval(self):
        """Assert files uploaded are retrieved from swarm"""
        for bzz_hash in self.bzz_hashes:
            with self.subTest(bzz_hash=bzz_hash):
                print(bzz_hash)
                cmd = CurlCommand(
                    'http://localhost:8500/bzz:/{}'.format(bzz_hash))
                exit_code, output = self.container.exec(cmd)
                self.assertEqual(exit_code, 0)
                self.assertGreater(len(output), 1)


if __name__ == '__main__':
    testdocker.main()
