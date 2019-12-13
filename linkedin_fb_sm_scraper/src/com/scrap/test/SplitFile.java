package com.scrap.test;

public class SplitFile {
    public static void main(String args[]) {
        String str = "safkasdjg";

        String[] str_split = str.split("\\|");

        System.out.println(str_split.length);
    }
}
