//
// ASCII.swift
// Author: Alexey Komnin
//

public enum ASCII: UInt8 {
    case NUL    = 0
    
    case SOH    = 0x01
    case STX    = 0x02
    case ETX    = 0x03
    case EOT    = 0x04
    case ENQ    = 0x05
    case ACK    = 0x06
    case BEL    = 0x07
    case BS     = 0x08
    case TAB    = 0x09
    case LF     = 0x0A
    case VT     = 0x0B
    case FF     = 0x0C
    case CR     = 0x0D
    case SO     = 0x0E
    case SI     = 0x0F
    
    case SPACE  = 0x20
    case EMARK  = 0x21
    case DQUOT  = 0x22
    case SHRP   = 0x23
    case DOL    = 0x24
    case PERC   = 0x25
    case AMP    = 0x26
    case SQUOT  = 0x27
    case LPAR   = 0x28
    case RPAR   = 0x29
    case STAR   = 0x2A
    case PLS    = 0x2B
    case COM    = 0x2C
    case MNS    = 0x2D
    case DOT    = 0x2E
    case BSLSH  = 0x2F
    
    case NUM0   = 0x30
    case NUM1   = 0x31
    case NUM2   = 0x32
    case NUM3   = 0x33
    case NUM4   = 0x34
    case NUM5   = 0x35
    case NUM6   = 0x36
    case NUM7   = 0x37
    case NUM8   = 0x38
    case NUM9   = 0x39
    case COL    = 0x3A
    case SEM    = 0x3B
    case LT     = 0x3C
    case EQ     = 0x3D
    case GT     = 0x3E
    case QMARK  = 0x3F
    
    case AT     = 0x40
    
    case CHR_A  = 0x41
    case CHR_B  = 0x42
    case CHR_C  = 0x43
    case CHR_D  = 0x44
    case CHR_E  = 0x45
    case CHR_F  = 0x46
    case CHR_G  = 0x47
    case CHR_H  = 0x48
    case CHR_I  = 0x49
    case CHR_J  = 0x4A
    case CHR_K  = 0x4B
    case CHR_L  = 0x4C
    case CHR_M  = 0x4D
    case CHR_N  = 0x4E
    case CHR_O  = 0x4F
    
    case CHR_P  = 0x50
    case CHR_Q  = 0x51
    case CHR_R  = 0x52
    case CHR_S  = 0x53
    case CHR_T  = 0x54
    case CHR_U  = 0x55
    case CHR_V  = 0x56
    case CHR_W  = 0x57
    case CHR_X  = 0x58
    case CHR_Y  = 0x59
    case CHR_Z  = 0x5A
    case LSQ    = 0x5B
    case SLSH   = 0x5C
    case RSQ    = 0x5D
    case CAR    = 0x5E
    case USCR   = 0x5F
    
    case CHR_a  = 0x61
    case CHR_b  = 0x62
    case CHR_c  = 0x63
    case CHR_d  = 0x64
    case CHR_e  = 0x65
    case CHR_f  = 0x66
    case CHR_g  = 0x67
    case CHR_h  = 0x68
    case CHR_i  = 0x69
    case CHR_j  = 0x6A
    case CHR_k  = 0x6B
    case CHR_l  = 0x6C
    case CHR_m  = 0x6D
    case CHR_n  = 0x6E
    case CHR_o  = 0x6F
    
    case CHR_p  = 0x70
    case CHR_q  = 0x71
    case CHR_r  = 0x72
    case CHR_s  = 0x73
    case CHR_t  = 0x74
    case CHR_u  = 0x75
    case CHR_v  = 0x76
    case CHR_w  = 0x77
    case CHR_x  = 0x78
    case CHR_y  = 0x79
    case CHR_z  = 0x7A
    
    case LBR    = 0x7B
    case VL     = 0x7C
    case RBR    = 0x7D
    case TLD    = 0x7E
}

extension ASCII: Comparable {}
public func < (lhs: ASCII, rhs: ASCII) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public extension ASCII {
    func isDigit() -> Bool {
        return self >= .NUM0 && self <= .NUM9
    }
    func isHexDigit() -> Bool {
        return isDigit() ||
            (self >= .CHR_a && self <= .CHR_f) ||
            (self >= .CHR_A && self <= .CHR_F)
    }
    func isCharacter() -> Bool {
        return (self >= .CHR_a && self <= .CHR_z) ||
               (self >= .CHR_A && self <= .CHR_Z)
    }
}
