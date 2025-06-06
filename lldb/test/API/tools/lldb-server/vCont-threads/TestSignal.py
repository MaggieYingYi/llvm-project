import re

import gdbremote_testcase
from lldbsuite.test.decorators import *
from lldbsuite.test.lldbtest import *
from lldbsuite.test import lldbutil


class TestSignal(gdbremote_testcase.GdbRemoteTestCaseBase):
    def start_threads(self, num):
        procs = self.prep_debug_monitor_and_inferior(inferior_args=[str(num)])
        self.test_sequence.add_log_lines(
            [
                "read packet: $c#63",
                {"direction": "send", "regex": "[$]T.*;reason:signal.*"},
            ],
            True,
        )
        self.add_threadinfo_collection_packets()

        context = self.expect_gdbremote_sequence()
        self.assertIsNotNone(context)
        threads = self.parse_threadinfo_packets(context)
        self.assertIsNotNone(threads)
        self.assertEqual(len(threads), num + 1)

        self.reset_test_sequence()
        return threads

    SIGNAL_MATCH_RE = re.compile(r"received SIGUSR1 on thread id: ([0-9a-f]+)")

    def send_and_check_signal(self, vCont_data, threads):
        self.test_sequence.add_log_lines(
            [
                "read packet: $vCont;{0}#00".format(vCont_data),
                "send packet: $W00#00",
            ],
            True,
        )
        exp = self.expect_gdbremote_sequence()
        self.reset_test_sequence()
        tids = []
        for line in exp["O_content"].decode().splitlines():
            m = self.SIGNAL_MATCH_RE.match(line)
            if m is not None:
                tids.append(int(m.group(1), 16))
        self.assertEqual(sorted(tids), sorted(threads))

    def get_pid(self):
        self.add_process_info_collection_packets()
        context = self.expect_gdbremote_sequence()
        self.assertIsNotNone(context)
        procinfo = self.parse_process_info_response(context)
        return int(procinfo["pid"], 16)

    @skipIfWindows
    @skipIfDarwin
    @expectedFailureNetBSD
    @expectedFailureAll(
        oslist=["freebsd"], bugnumber="github.com/llvm/llvm-project/issues/56086"
    )
    @skipIfAsan  # Times out under asan
    @skipIf(oslist=["linux"], archs=["arm$", "aarch64"])  # Randomly fails on buildbot
    def test_signal_process_without_tid(self):
        self.build()
        self.set_inferior_startup_launch()

        threads = self.start_threads(1)
        self.send_and_check_signal(
            "C{0:x}".format(lldbutil.get_signal_number("SIGUSR1")), threads
        )

    @skipUnlessPlatform(["netbsd"])
    @expectedFailureNetBSD
    @skipIfAsan  # Times out under asan
    @skipIf(oslist=["linux"], archs=["arm$", "aarch64"])  # Randomly fails on buildbot
    def test_signal_one_thread(self):
        self.build()
        self.set_inferior_startup_launch()

        threads = self.start_threads(1)
        # try sending a signal to one of the two threads
        self.send_and_check_signal(
            "C{0:x}:{1:x};c".format(lldbutil.get_signal_number("SIGUSR1")), threads[:1]
        )

    @skipIfWindows
    @skipIfDarwin
    @expectedFailureNetBSD
    @expectedFailureAll(
        oslist=["freebsd"], bugnumber="github.com/llvm/llvm-project/issues/56086"
    )
    @skipIfAsan  # Times out under asan
    @skipIf(oslist=["linux"], archs=["arm$", "aarch64"])  # Randomly fails on buildbot
    def test_signal_all_threads(self):
        self.build()
        self.set_inferior_startup_launch()

        threads = self.start_threads(1)
        # try sending a signal to two threads (= the process)
        self.send_and_check_signal(
            "C{0:x}:{1:x};C{0:x}:{2:x}".format(
                lldbutil.get_signal_number("SIGUSR1"), *threads
            ),
            threads,
        )

    @skipIfWindows
    @expectedFailureNetBSD
    @expectedFailureAll(
        oslist=["freebsd"], bugnumber="github.com/llvm/llvm-project/issues/56086"
    )
    @add_test_categories(["llgs"])
    @skipIfAsan  # Times out under asan
    @skipIf(oslist=["linux"], archs=["arm$", "aarch64"])  # Randomly fails on buildbot
    def test_signal_process_by_pid(self):
        self.build()
        self.set_inferior_startup_launch()

        threads = self.start_threads(1)
        self.send_and_check_signal(
            "C{0:x}:p{1:x}".format(
                lldbutil.get_signal_number("SIGUSR1"), self.get_pid()
            ),
            threads,
        )

    @skipIfWindows
    @expectedFailureNetBSD
    @expectedFailureAll(
        oslist=["freebsd"], bugnumber="github.com/llvm/llvm-project/issues/56086"
    )
    @add_test_categories(["llgs"])
    @skipIfAsan  # Times out under asan
    @skipIf(oslist=["linux"], archs=["arm$", "aarch64"])  # Randomly fails on buildbot
    def test_signal_process_minus_one(self):
        self.build()
        self.set_inferior_startup_launch()

        threads = self.start_threads(1)
        self.send_and_check_signal(
            "C{0:x}:p-1".format(lldbutil.get_signal_number("SIGUSR1")), threads
        )

    @skipIfWindows
    @expectedFailureNetBSD
    @expectedFailureAll(
        oslist=["freebsd"], bugnumber="github.com/llvm/llvm-project/issues/56086"
    )
    @add_test_categories(["llgs"])
    @skipIf(oslist=["linux"], archs=["arm$", "aarch64"])  # Randomly fails on buildbot
    def test_signal_minus_one(self):
        self.build()
        self.set_inferior_startup_launch()

        threads = self.start_threads(1)
        self.send_and_check_signal(
            "C{0:x}:-1".format(lldbutil.get_signal_number("SIGUSR1")), threads
        )

    @skipIfWindows
    @expectedFailureNetBSD
    @expectedFailureAll(
        oslist=["freebsd"], bugnumber="github.com/llvm/llvm-project/issues/56086"
    )
    @add_test_categories(["llgs"])
    @skipIfAsan  # Times out under asan
    @skipIf(oslist=["linux"], archs=["arm$", "aarch64"])  # Randomly fails on buildbot
    def test_signal_all_threads_by_pid(self):
        self.build()
        self.set_inferior_startup_launch()

        threads = self.start_threads(1)
        # try sending a signal to two threads (= the process)
        self.send_and_check_signal(
            "C{0:x}:p{1:x}.{2:x};C{0:x}:p{1:x}.{3:x}".format(
                lldbutil.get_signal_number("SIGUSR1"), self.get_pid(), *threads
            ),
            threads,
        )

    @skipIfWindows
    @expectedFailureNetBSD
    @expectedFailureAll(
        oslist=["freebsd"], bugnumber="github.com/llvm/llvm-project/issues/56086"
    )
    @add_test_categories(["llgs"])
    @skipIfAsan  # Times out under asan
    @skipIf(oslist=["linux"], archs=["arm$", "aarch64"])  # Randomly fails on buildbot
    def test_signal_minus_one_by_pid(self):
        self.build()
        self.set_inferior_startup_launch()

        threads = self.start_threads(1)
        self.send_and_check_signal(
            "C{0:x}:p{1:x}.-1".format(
                lldbutil.get_signal_number("SIGUSR1"), self.get_pid()
            ),
            threads,
        )

    @skipIfWindows
    @expectedFailureNetBSD
    @expectedFailureAll(
        oslist=["freebsd"], bugnumber="github.com/llvm/llvm-project/issues/56086"
    )
    @add_test_categories(["llgs"])
    @skipIfAsan  # Times out under asan
    @skipIf(oslist=["linux"], archs=["arm$", "aarch64"])  # Randomly fails on buildbot
    def test_signal_minus_one_by_minus_one(self):
        self.build()
        self.set_inferior_startup_launch()

        threads = self.start_threads(1)
        self.send_and_check_signal(
            "C{0:x}:p-1.-1".format(lldbutil.get_signal_number("SIGUSR1")), threads
        )

    @skipUnlessPlatform(["netbsd"])
    @skipIf(oslist=["linux"], archs=["arm$", "aarch64"])  # Randomly fails on buildbot
    def test_signal_two_of_three_threads(self):
        self.build()
        self.set_inferior_startup_launch()

        threads = self.start_threads(2)
        # try sending a signal to 2 out of 3 threads
        self.test_sequence.add_log_lines(
            [
                "read packet: $vCont;C{0:x}:{1:x};C{0:x}:{2:x};c#00".format(
                    lldbutil.get_signal_number("SIGUSR1"), threads[1], threads[2]
                ),
                {"direction": "send", "regex": r"^\$E1e#db$"},
            ],
            True,
        )

        context = self.expect_gdbremote_sequence()
        self.assertIsNotNone(context)

    @skipUnlessPlatform(["netbsd"])
    @skipIf(oslist=["linux"], archs=["arm$", "aarch64"])  # Randomly fails on buildbot
    def test_signal_two_signals(self):
        self.build()
        self.set_inferior_startup_launch()

        threads = self.start_threads(1)
        # try sending two different signals to two threads
        self.test_sequence.add_log_lines(
            [
                "read packet: $vCont;C{0:x}:{1:x};C{2:x}:{3:x}#00".format(
                    lldbutil.get_signal_number("SIGUSR1"),
                    threads[0],
                    lldbutil.get_signal_number("SIGUSR2"),
                    threads[1],
                ),
                {"direction": "send", "regex": r"^\$E1e#db$"},
            ],
            True,
        )

        context = self.expect_gdbremote_sequence()
        self.assertIsNotNone(context)
