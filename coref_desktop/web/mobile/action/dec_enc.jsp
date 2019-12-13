<%@ page import="java.security.NoSuchProviderException" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%@ page import="java.security.InvalidKeyException" %>
<%@ page import="java.security.InvalidAlgorithmParameterException" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="javax.crypto.spec.IvParameterSpec" %>
<%@ page import="javax.crypto.*" %>
<%@ page import="java.io.*" %>

<%!
    static String keyString = "876983260912873459082341";

    static final byte[] ivBytes = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07};

    public static byte[] processEncrypt(String mobile) throws NoSuchProviderException, NoSuchAlgorithmException,
            NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException,
            IOException, IllegalBlockSizeException, BadPaddingException {
        byte[] keyBytes = keyString.getBytes();
        SecretKey secKey = new SecretKeySpec(keyBytes, "DESede");
        IvParameterSpec iv = new IvParameterSpec(ivBytes);
        Cipher encryptCipher = null;
        encryptCipher = Cipher.getInstance("DESede/CBC/PKCS5Padding", "SunJCE");
        encryptCipher.init(javax.crypto.Cipher.ENCRYPT_MODE, secKey, iv);

        byte[] mobile_ba = mobile.getBytes();

        byte[] encryptedBytes = encryptCipher.doFinal(mobile_ba);

        return encryptedBytes;
    }

    public byte[] processDecrypt(byte[] enc_mobile)  throws NoSuchProviderException, NoSuchAlgorithmException,
            NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException,
            IOException, IllegalBlockSizeException, BadPaddingException {
        byte[] keyBytes = keyString.getBytes();
        SecretKey secKey = new SecretKeySpec(keyBytes, "DESede");
        IvParameterSpec iv = new IvParameterSpec(ivBytes);
        Cipher decryptCipher = null;
        decryptCipher = Cipher.getInstance("DESede/CBC/PKCS5Padding", "SunJCE");
        decryptCipher.init(javax.crypto.Cipher.DECRYPT_MODE, secKey, iv);

        byte[] decryptedBytes = decryptCipher.doFinal(enc_mobile);

        return decryptedBytes;
    }
%>
