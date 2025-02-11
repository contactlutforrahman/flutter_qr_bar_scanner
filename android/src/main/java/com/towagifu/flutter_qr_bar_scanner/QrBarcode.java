package com.towagifu.flutter_qr_bar_scanner;

import android.graphics.Rect;
import com.google.mlkit.vision.barcode.common.Barcode;
import java.util.HashMap;
import java.util.Map;

public class QrBarcode {
    private final Barcode _barcode;

    public QrBarcode(Barcode barcode) {
        _barcode = barcode;
    }

    public String getContent() {
        return _barcode.getRawValue();
    }

    public byte[] getBytes() {
        return _barcode.getRawBytes();
    }

    public Rect getBoundingBox() {
        return _barcode.getBoundingBox();
    }

    public BarcodeFormats getFormat() {
        return BarcodeFormats.getFromValue(_barcode.getFormat());
    }

    public Map<String, Object> getForChannel() {
        Map<String, Object> ret = new HashMap<>();

        ret.put("content", getContent());
        ret.put("bytes", getBytes());
        ret.put("format", getFormat().name());

        Map<String, Integer> boundingBox = new HashMap<>();
        Rect bb = getBoundingBox();
        boundingBox.put("bottom", bb.bottom);
        boundingBox.put("left", bb.left);
        boundingBox.put("right", bb.right);
        boundingBox.put("top", bb.top);

        ret.put("bounds", boundingBox);

        return ret;
    }
}