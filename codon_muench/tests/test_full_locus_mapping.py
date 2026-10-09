"""Regressions for retained full-locus mapping; manuscript use remains unconfirmed."""
import importlib.util
import os
from pathlib import Path
import sys
import unittest

ROOT = Path(os.environ.get('OPERON_ANALYSIS_ROOT', Path(__file__).resolve().parents[1]))


def load(relative):
    path = ROOT / relative
    name = 'audit_' + relative.replace('/', '_').replace('.', '_')
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


class FullLocusMappingTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mapping = load('13e_full_operon_mapping/compare_full_operon_mapping.py')
        cls.raw = load('13e_full_operon_mapping/process_raw_blast.py')
        cls.variants = load('13e_full_operon_mapping/analyze_updated_operon_variants.py')

    def test_query_coverage_excludes_subject_insertions(self):
        hit = self.mapping.BlastHit('c', 99, 110, 0, 100, 1, 80, 1, 110, 100, 'A'*80+'-'*30, 'A'*110)
        raw_hit = self.raw.BlastAlignment(99, 110, 100, 1, 80, 100, hit.qseq, hit.sseq)
        self.assertEqual(hit.coverage, 80)
        self.assertEqual(raw_hit.coverage, 80)

    def test_missing_insertion_site_is_missing(self):
        v = self.variants
        aln = v.Alignment('contig', 100, 3, 0, 0, 1, 3, 1, 3, 0, 100, 8000, 'AAA', 'AAA')
        bundle = v.SubjectBundle([aln], 8000, 3, 100)
        bases, insertions = v.extract_calls(bundle)
        self.assertEqual(v.aggregate_sites(bases, insertions)['7501^7502'], 'missing')

    def test_covered_insertion_present_and_absent(self):
        v = self.variants
        for q, s, length, expected in [('AA', 'AA', 2, 'absent'), ('A-A', 'AAA', 3, 'A')]:
            aln = v.Alignment('c', 100, length, 0, 0, 7501, 7502, 1, length, 0, 100, 8000, q, s)
            bases, insertions = v.extract_calls(v.SubjectBundle([aln], 8000, 2, 100))
            self.assertEqual(v.aggregate_sites(bases, insertions)['7501^7502'], expected)

    def test_overlapping_hsps_do_not_inflate_coverage(self):
        v = self.variants
        aln = v.Alignment('c', 100, 3, 0, 0, 1, 3, 1, 3, 0, 100, 10, 'AAA', 'AAA')
        bundle = v.SubjectBundle([aln, aln], 10, 6, 200)
        self.assertIsNone(v.select_best_bundle({'c': bundle}, 50))

if __name__ == '__main__':
    unittest.main()
