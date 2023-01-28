#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
from functools import cmp_to_key
import os
import shutil


def num_string(str):
    num = "0123456789"
    ret = ""
    for i in range(len(str)):
        o = str[i]
        if num.find(o) != -1:
            ret += o
        else:
            if len(ret) > 0:
                e = ret[len(ret) - 1]
                if num.find(e) != -1:
                    ret += "."

    if len(ret) == 0:
        return "0"
    return ret


def compare_num_str(n1, n2):
    a1 = n1.split(".")
    a2 = n2.split(".")

    if len(a1) < len(a2):
        return -1
    elif len(a1) > len(a2):
        return 1
    else:
        for i in range(len(a1)):
            step1 = int(a1[i])
            step2 = int(a2[i])

            if step1 < step2:
                return -1
            elif step1 > step2:
                return 1
    return 0


def random_string(len):
    import random
    lib = "abcdefghijklmnopqrstuvwxyz"
    ret = ""
    for i in range(len):
        l = random.randint(0, 25)
        u = random.randint(0, 1)

        if u:
            ret += lib[l].upper()
        else:
            ret += lib[l].lower()
    return ret


def compare_num_name(n1, n2):

    n1 = os.path.splitext(n1)[0]
    n1 = num_string(n1)
    n2 = os.path.splitext(n2)[0]
    n2 = num_string(n2)

    return compare_num_str(n1, n2)


def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--folder", help="source folder")
    parser.add_argument("-e", "--ext", help="file extension")
    parser.add_argument("-p", "--prefix", help="use file name with prefix")
    parser.add_argument("-s", "--suffix", help="use file name with suffix")

    parser.add_argument("-r", "--replace", help="replace string")
    parser.add_argument(
        "-c", "--clear", help="clear name string", default=False)
    parser.add_argument("-rp", "--remove_prefix", help="remove prefix")
    parser.add_argument("-rs", "--remove_suffix", help="remove suffix")
    parser.add_argument("-ap", "--add_prefix", help="add prefix")
    parser.add_argument("-as", "--append_suffix", help="append suffix")
    parser.add_argument("-n", "--num", help="append suffix number start from")
    parser.add_argument("-rand", "--random_name", help="random name")
    args = parser.parse_args()

    src_folder = args.folder
    if src_folder is None or not os.path.exists(src_folder):
        parser.print_help()
        return

    des_folder = str(src_folder).removesuffix(os.pathsep) + "_sorted"

    if not os.path.exists(des_folder):
        os.makedirs(des_folder)

    array = os.listdir(src_folder)
    if not array:
        print("source folder is empty!")
        return

    if args.ext:
        new_array = []
        for name in array:
            if name.endswith(args.ext):
                new_array.append(name)
        array = new_array

    if args.prefix:
        new_array = []
        for name in array:
            if name.startswith(args.prefix):
                new_array.append(name)
        array = new_array

    if args.suffix:
        new_array = []
        for name in array:
            if name.endswith(args.suffix):
                new_array.append(name)
        array = new_array

    array.sort(key=cmp_to_key(compare_num_name))

    number_len = 0
    if args.num:
        power10 = 0
        for i in range(100):
            power10 = pow(10, i)
            if power10 >= len(array):
                number_len = i
                break

    j = 0
    for i in range(len(array)):
        name = array[i]
        if name == ".DS_Store":
            continue

        name_without_ext = os.path.splitext(name)[0]
        ext = os.path.splitext(name)[1]

        if args.random_name:
            name_without_ext = random_string(int(args.random_name))

        if args.clear:
            name_without_ext = ""

        if args.remove_prefix:
            if name_without_ext.startswith(args.remove_prefix):
                name_without_ext = name_without_ext[len(
                    args.remove_prefix):]

        if args.remove_suffix:
            if name_without_ext.endswith(args.remove_suffix):
                name_without_ext = name_without_ext[:len(
                    name_without_ext) - len(args.remove_suffix)]

        if args.replace:
            name_without_ext = name_without_ext.replace(args.replace, "")

        if args.add_prefix:
            name_without_ext = args.add_prefix + name_without_ext

        if args.append_suffix:
            name_without_ext = name_without_ext + args.append_suffix

        if args.num:
            name_without_ext = "{:0{width}}".format(
                j + int(args.num), width=number_len)
            j += 1

        src_path = os.path.join(src_folder, name)
        des_path = os.path.join(des_folder, name_without_ext + ext)

        try:
            shutil.copy(src_path, des_path)
            print("copied [%s] to [%s] !" % (src_path, des_path))
        except Exception as e:
            print("copy [%s] to [%s] failed!" % (src_path, des_path))
    print("done!")


if __name__ == "__main__":
    main()
