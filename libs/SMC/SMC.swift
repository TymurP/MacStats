//
//  SMC.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 22.11.20.
//

import Foundation

//------------------------------------------------------------------------------
// MARK: Type Aliases
//------------------------------------------------------------------------------
// http://stackoverflow.com/a/22383661
/// Floating point, unsigned, 14 bits exponent, 2 bits fraction
public typealias FPE2 = (UInt8, UInt8)

/// Floating point, signed, 7 bits exponent, 8 bits fraction
public typealias SP78 = (UInt8, UInt8)

public typealias SMCBytes = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                             UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                             UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                             UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                             UInt8, UInt8, UInt8, UInt8)

public extension FourCharCode {
    
    init(fromString str: String) {
        precondition(str.count == 4)
        
        self = str.utf8.reduce(0) { sum, character in
            return sum << 8 | UInt32(character)
        }
    }
    
    init(fromStaticString str: StaticString) {
        precondition(str.utf8CodeUnitCount == 4)
        
        self = str.withUTF8Buffer { buffer in
            // TODO: Broken up due to "Expression was too complex" error as of
            //       Swift 4.
            let byte0 = UInt32(buffer[0]) << 24
            let byte1 = UInt32(buffer[1]) << 16
            let byte2 = UInt32(buffer[2]) << 8
            let byte3 = UInt32(buffer[3])
            
            return byte0 | byte1 | byte2 | byte3
        }
    }
    
    func toString() -> String {
        return String(describing: UnicodeScalar(self >> 24 & 0xff)!) +
            String(describing: UnicodeScalar(self >> 16 & 0xff)!) +
            String(describing: UnicodeScalar(self >> 8  & 0xff)!) +
            String(describing: UnicodeScalar(self       & 0xff)!)
    }
}

extension Double {
    
    init(fromSP78 bytes: SP78) {
        // FIXME: Handle second byte
        let sign = bytes.0 & 0x80 == 0 ? 1.0 : -1.0
        self = sign * Double(bytes.0 & 0x7F)    // AND to mask sign bit
    }
}

/// SMC data type information
private struct DataTypes {
    /// Fan information struct
    public static let FDS =
        DataType(type: FourCharCode(fromStaticString: "{fds"), size: 16)
    public static let Flag =
        DataType(type: FourCharCode(fromStaticString: "flag"), size: 1)
    /// See type aliases
    public static let FPE2 =
        DataType(type: FourCharCode(fromStaticString: "fpe2"), size: 2)
    public static let FLT =
        DataType(type: FourCharCode(fromStaticString: "flt "), size: 4)
    /// See type aliases
    public static let SP78 =
        DataType(type: FourCharCode(fromStaticString: "sp78"), size: 2)
    public static let UInt8 =
        DataType(type: FourCharCode(fromStaticString: "ui8 "), size: 1)
    public static let UInt16 =
        DataType(type: FourCharCode(fromStaticString: "ui16"), size: 2)
    public static let UInt32 =
        DataType(type: FourCharCode(fromStaticString: "ui32"), size: 4)
}

private struct SMCKey {
    let code: FourCharCode
    let info: DataType
}

private struct DataType: Equatable {
    let type: FourCharCode
    let size: UInt32
}

public struct SMCParamStruct {
    
    /// I/O Kit function selector
    public enum Selector: UInt8 {
        case kSMCHandleYPCEvent  = 2
        case kSMCReadKey         = 5
        case kSMCWriteKey        = 6
        case kSMCGetKeyFromIndex = 8
        case kSMCGetKeyInfo      = 9
    }
    
    /// Return codes for SMCParamStruct.result property
    public enum Result: UInt8 {
        case kSMCSuccess     = 0
        case kSMCError       = 1
        case kSMCKeyNotFound = 132
    }
    
    public struct SMCVersion {
        var major: CUnsignedChar = 0
        var minor: CUnsignedChar = 0
        var build: CUnsignedChar = 0
        var reserved: CUnsignedChar = 0
        var release: CUnsignedShort = 0
    }
    
    public struct SMCPLimitData {
        var version: UInt16 = 0
        var length: UInt16 = 0
        var cpuPLimit: UInt32 = 0
        var gpuPLimit: UInt32 = 0
        var memPLimit: UInt32 = 0
    }
    
    public struct SMCKeyInfoData {
        /// How many bytes written to SMCParamStruct.bytes
        var dataSize: IOByteCount = 0
        
        /// Type of data written to SMCParamStruct.bytes. This lets us know how
        /// to interpret it (translate it to human readable)
        var dataType: UInt32 = 0
        
        var dataAttributes: UInt8 = 0
    }
    
    /// FourCharCode telling the SMC what we want
    var key: UInt32 = 0
    
    var vers = SMCVersion()
    
    var pLimitData = SMCPLimitData()
    
    var keyInfo = SMCKeyInfoData()
    
    /// Padding for struct alignment when passed over to C side
    var padding: UInt16 = 0
    
    /// Result of an operation
    var result: UInt8 = 0
    
    var status: UInt8 = 0
    
    /// Method selector
    var data8: UInt8 = 0
    
    var data32: UInt32 = 0
    
    /// Data returned from the SMC
    var bytes: SMCBytes = (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                           UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                           UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                           UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                           UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                           UInt8(0), UInt8(0))
}

public struct TemperatureSensors {
    
    public static let AMBIENT_AIR_0 = TemperatureSensor(name: "AMBIENT_AIR_0",
                                                        code: FourCharCode(fromStaticString: "TA0P"))
    public static let AMBIENT_AIR_1 = TemperatureSensor(name: "AMBIENT_AIR_1",
                                                        code: FourCharCode(fromStaticString: "TA1P"))
    // Via powermetrics(1)
    public static let CPU_0_DIE = TemperatureSensor(name: "CPU_0_DIE",
                                                    code: FourCharCode(fromStaticString: "TC0F"))
    public static let CPU_0_DIODE = TemperatureSensor(name: "CPU_0_DIODE",
                                                      code: FourCharCode(fromStaticString: "TC0D"))
    public static let CPU_0_HEATSINK = TemperatureSensor(name: "CPU_0_HEATSINK",
                                                         code: FourCharCode(fromStaticString: "TC0H"))
    public static let CPU_0_PROXIMITY =
        TemperatureSensor(name: "CPU_0_PROXIMITY",
                          code: FourCharCode(fromStaticString: "TC0P"))
    public static let ENCLOSURE_BASE_0 =
        TemperatureSensor(name: "ENCLOSURE_BASE_0",
                          code: FourCharCode(fromStaticString: "TB0T"))
    public static let ENCLOSURE_BASE_1 =
        TemperatureSensor(name: "ENCLOSURE_BASE_1",
                          code: FourCharCode(fromStaticString: "TB1T"))
    public static let ENCLOSURE_BASE_2 =
        TemperatureSensor(name: "ENCLOSURE_BASE_2",
                          code: FourCharCode(fromStaticString: "TB2T"))
    public static let ENCLOSURE_BASE_3 =
        TemperatureSensor(name: "ENCLOSURE_BASE_3",
                          code: FourCharCode(fromStaticString: "TB3T"))
    public static let GPU_0_DIODE = TemperatureSensor(name: "GPU_0_DIODE",
                                                      code: FourCharCode(fromStaticString: "TG0D"))
    public static let GPU_0_HEATSINK = TemperatureSensor(name: "GPU_0_HEATSINK",
                                                         code: FourCharCode(fromStaticString: "TG0H"))
    public static let GPU_0_PROXIMITY =
        TemperatureSensor(name: "GPU_0_PROXIMITY",
                          code: FourCharCode(fromStaticString: "TG0P"))
    public static let HDD_PROXIMITY = TemperatureSensor(name: "HDD_PROXIMITY",
                                                        code: FourCharCode(fromStaticString: "TH0P"))
    public static let HEATSINK_0 = TemperatureSensor(name: "HEATSINK_0",
                                                     code: FourCharCode(fromStaticString: "Th0H"))
    public static let HEATSINK_1 = TemperatureSensor(name: "HEATSINK_1",
                                                     code: FourCharCode(fromStaticString: "Th1H"))
    public static let HEATSINK_2 = TemperatureSensor(name: "HEATSINK_2",
                                                     code: FourCharCode(fromStaticString: "Th2H"))
    public static let LCD_PROXIMITY = TemperatureSensor(name: "LCD_PROXIMITY",
                                                        code: FourCharCode(fromStaticString: "TL0P"))
    public static let MEM_SLOT_0 = TemperatureSensor(name: "MEM_SLOT_0",
                                                     code: FourCharCode(fromStaticString: "TM0S"))
    public static let MEM_SLOTS_PROXIMITY =
        TemperatureSensor(name: "MEM_SLOTS_PROXIMITY",
                          code: FourCharCode(fromStaticString: "TM0P"))
    public static let MISC_PROXIMITY = TemperatureSensor(name: "MISC_PROXIMITY",
                                                         code: FourCharCode(fromStaticString: "Tm0P"))
    public static let NORTHBRIDGE = TemperatureSensor(name: "NORTHBRIDGE",
                                                      code: FourCharCode(fromStaticString: "TN0H"))
    public static let NORTHBRIDGE_DIODE =
        TemperatureSensor(name: "NORTHBRIDGE_DIODE",
                          code: FourCharCode(fromStaticString: "TN0D"))
    public static let NORTHBRIDGE_PROXIMITY =
        TemperatureSensor(name: "NORTHBRIDGE_PROXIMITY",
                          code: FourCharCode(fromStaticString: "TN0P"))
    public static let ODD_PROXIMITY = TemperatureSensor(name: "ODD_PROXIMITY",
                                                        code: FourCharCode(fromStaticString: "TO0P"))
    public static let PALM_REST = TemperatureSensor(name: "PALM_REST",
                                                    code: FourCharCode(fromStaticString: "Ts0P"))
    public static let PWR_SUPPLY_PROXIMITY =
        TemperatureSensor(name: "PWR_SUPPLY_PROXIMITY",
                          code: FourCharCode(fromStaticString: "Tp0P"))
    public static let THUNDERBOLT_0 = TemperatureSensor(name: "THUNDERBOLT_0",
                                                        code: FourCharCode(fromStaticString: "TI0P"))
    public static let THUNDERBOLT_1 = TemperatureSensor(name: "THUNDERBOLT_1",
                                                        code: FourCharCode(fromStaticString: "TI1P"))
    
    public static let all = [AMBIENT_AIR_0.code : AMBIENT_AIR_0,
                             AMBIENT_AIR_1.code : AMBIENT_AIR_1,
                             CPU_0_DIE.code : CPU_0_DIE,
                             CPU_0_DIODE.code : CPU_0_DIODE,
                             CPU_0_HEATSINK.code : CPU_0_HEATSINK,
                             CPU_0_PROXIMITY.code : CPU_0_PROXIMITY,
                             ENCLOSURE_BASE_0.code : ENCLOSURE_BASE_0,
                             ENCLOSURE_BASE_1.code : ENCLOSURE_BASE_1,
                             ENCLOSURE_BASE_2.code : ENCLOSURE_BASE_2,
                             ENCLOSURE_BASE_3.code : ENCLOSURE_BASE_3,
                             GPU_0_DIODE.code : GPU_0_DIODE,
                             GPU_0_HEATSINK.code : GPU_0_HEATSINK,
                             GPU_0_PROXIMITY.code : GPU_0_PROXIMITY,
                             HDD_PROXIMITY.code : HDD_PROXIMITY,
                             HEATSINK_0.code : HEATSINK_0,
                             HEATSINK_1.code : HEATSINK_1,
                             HEATSINK_2.code : HEATSINK_2,
                             MEM_SLOT_0.code : MEM_SLOT_0,
                             MEM_SLOTS_PROXIMITY.code: MEM_SLOTS_PROXIMITY,
                             PALM_REST.code : PALM_REST,
                             LCD_PROXIMITY.code : LCD_PROXIMITY,
                             MISC_PROXIMITY.code : MISC_PROXIMITY,
                             NORTHBRIDGE.code : NORTHBRIDGE,
                             NORTHBRIDGE_DIODE.code : NORTHBRIDGE_DIODE,
                             NORTHBRIDGE_PROXIMITY.code : NORTHBRIDGE_PROXIMITY,
                             ODD_PROXIMITY.code : ODD_PROXIMITY,
                             PWR_SUPPLY_PROXIMITY.code : PWR_SUPPLY_PROXIMITY,
                             THUNDERBOLT_0.code : THUNDERBOLT_0,
                             THUNDERBOLT_1.code : THUNDERBOLT_1]
}

public struct TemperatureSensor {
    public let name: String
    public let code: FourCharCode
}

public enum TemperatureUnit {
    case celius
    case fahrenheit
    case kelvin
    
    public static func toFahrenheit(_ celius: Float) -> Float {
        // https://en.wikipedia.org/wiki/Fahrenheit#Definition_and_conversions
        return Float((celius * 1.8) + 32)
    }
    
    public static func toKelvin(_ celius: Float) -> Float {
        // https://en.wikipedia.org/wiki/Kelvin
        return Float(celius + 273.15)
    }
}

public struct SMC {
    
    /// Connection to the SMC driver
    fileprivate static var connection: io_connect_t = 0
    
    /**
     * Open connection to the SMC driver. This must be done first before any other calls.
     */
    public static func open() {
        smcWrapper.start()
    }
    
    /**
     * Set root privileges to the SCM binary
     */
    public static func runAsRoot() {
        smcWrapper.setRights()
    }
    
    /// Close connection to the SMC driver
    public static func close() {
        smcWrapper.cleanUp()
    }
    
    /// Get current temperature of a sensor
    public static func temperature(unit: TemperatureUnit = .celius) -> Float {
        let data = smcWrapper.getMainTemp()
        
        switch unit {
        case .celius:
            return data
        case .fahrenheit:
            return TemperatureUnit.toFahrenheit(data)
        case .kelvin:
            return TemperatureUnit.toKelvin(data)
        }
    }
    
    public static func getAllFans() -> Int {
        return Int(smcWrapper.getFanNum())
    }
    
    public static func getFanDesc(id: Int) -> String {
        return smcWrapper.getFanDescr(Int32(id))
    }
}
