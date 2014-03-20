
--------------------------------
-- @module CCCrypto

--------------------------------
-- @function [parent=#CCCrypto] encryptXXTEA 
-- @param self
-- @param #string str
-- @param #int int
-- @param #string str
-- @param #int int
-- @param #int int
-- @return Data#Data ret (return value: cc.Data)
        
--------------------------------
-- @function [parent=#CCCrypto] decryptXXTEA 
-- @param self
-- @param #string str
-- @param #int int
-- @param #unsigned char char
-- @param #int int
-- @param #int int
-- @return string#string ret (return value: string)
        
--------------------------------
-- @function [parent=#CCCrypto] decryptAES256 
-- @param self
-- @param #unsigned char char
-- @param #int int
-- @param #unsigned char char
-- @param #int int
-- @param #unsigned char char
-- @param #int int
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#CCCrypto] MD5File 
-- @param self
-- @param #char char
-- @param #unsigned char char
        
--------------------------------
-- @function [parent=#CCCrypto] decodeBase64Len 
-- @param self
-- @param #char char
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#CCCrypto] MD5String 
-- @param self
-- @param #void void
-- @param #int int
-- @return string#string ret (return value: string)
        
--------------------------------
-- @function [parent=#CCCrypto] encryptAES256 
-- @param self
-- @param #unsigned char char
-- @param #int int
-- @param #unsigned char char
-- @param #int int
-- @param #unsigned char char
-- @param #int int
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#CCCrypto] getAES256KeyLength 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#CCCrypto] encodeBase64 
-- @param self
-- @param #char char
-- @param #int int
-- @param #char char
-- @param #int int
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#CCCrypto] encodeBase64Len 
-- @param self
-- @param #char char
-- @param #int int
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#CCCrypto] isValidNativeObject 
-- @param self
-- @param #cc.Ref ref
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#CCCrypto] decodeBase64 
-- @param self
-- @param #char char
-- @param #char char
-- @param #int int
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#CCCrypto] MD5 
-- @param self
-- @param #void void
-- @param #int int
-- @param #unsigned char char
        
return nil
