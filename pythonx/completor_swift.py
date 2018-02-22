# -*- coding: utf-8 -*-

import re
import json
import os.path

from completor import Completor, vim
from completor.compat import to_unicode

path = os.path.dirname(__file__)

wrapper = os.path.join(path, '..', 'SourceKittenWrapper', '.build',
                       'release', 'SourceKittenWrapper')

pat = re.compile('\w+$|\.\s*\w*$', re.U)
placeholder = re.compile('<#T##([^#]+:\s*[^#]+##)?(?P<ty>[^#]+)#>', re.U)


def replace(match):
    matches = match.groupdict()
    return '<#{}#>'.format(matches['ty']) if 'ty' in matches else ''


class SourceKitten(Completor):
    filetype = 'swift'
    daemon = True
    args_file = '.sourcekitten_complete'

    def format_cmd(self):
        binary = self.get_option('sourcekittenwrapper_binary') or wrapper
        spm_module = self.get_option('sourcekitten_spm_module') or ''
        extra_args = self.get_option('sourcekitten_extra_args') or ''

        args = [binary]
        if spm_module:
            args.extend(['-spm-module', spm_module])
        if extra_args:
            args.extend(['-compiler-args', extra_args])
        else:
            file_args = self.parse_config(self.args_file)
            if file_args:
                args.extend(['-compiler-args', ' '.join(file_args)])
        return args

    def offset(self):
        line, col = vim.current.window.cursor
        line2byte = vim.Function('line2byte')
        return line2byte(line) + col - 1

    def start_column(self):
        col = super(SourceKitten, self).start_column()
        parts = self.input_data.rsplit()
        if parts and b'.' in parts[-1]:
            col -= 1
        return col

    def request(self, action=None):
        offset = self.offset() - 1
        match = pat.search(self.input_data)
        if not match:
            return ''
        start, end = match.span()
        offset -= end - start - 1

        return json.dumps({
            'content': '\n'.join(vim.current.buffer[:]),
            'offset': offset
        })

    def parse(self, items):
        res = []
        prefix = ''
        match = pat.search(self.input_data)
        if match:
            prefix = match.group()

        if prefix.startswith(b'.'):
            prefix = prefix.strip(b'.')

        try:
            data = to_unicode(items[0], 'utf-8')
            for item in json.loads(data):
                if not item[b'abbr'].startswith(prefix):
                    continue
                item[b'word'] = placeholder.sub(
                    replace, to_unicode(item[b'word'], 'utf-8'))
                item[b'menu'] = item[b'menu'].replace(
                    'source.lang.swift.decl.', '')
                res.append(item)
            return res
        except Exception:
            return []
