def get_crc32( string ):
    string = string.lower()        
    bytes = bytearray(string.encode())
    crc = 0xffffffff;
    for b in bytes:
        crc = crc ^ (b << 24)          
        for i in range(8):
            if (crc & 0x80000000 ):
                crc = (crc << 1) ^ 0x04C11DB7                
            else:
                crc = crc << 1;                        
        crc = crc & 0xFFFFFFFF
        
    return '%08x' % crc


print(get_crc32("nfs://datatank.local//data/new/movies/Movies-Transfer/2 Headed Shark Attack/w-2hsa-xvid.avi"));
