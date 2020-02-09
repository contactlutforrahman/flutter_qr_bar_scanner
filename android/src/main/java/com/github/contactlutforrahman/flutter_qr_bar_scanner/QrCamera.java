package com.github.contactlutforrahman.flutter_qr_bar_scanner;

interface QrCamera {
    void start() throws QrReader.Exception;
    void stop();
    int getOrientation();
    int getWidth();
    int getHeight();
}
