#ifndef BSP_MCU_DEVICE_PN_CFG_H_
#define BSP_MCU_DEVICE_PN_CFG_H_
#if defined(CONFIG_SOC_R7FA6M5BHxxFC)
    #define BSP_MCU_R7FA6M5BH3CFC
    #define BSP_MCU_FEATURE_SET ('B')
#endif

#define BSP_ROM_SIZE_BYTES (CONFIG_ROM_SIZE_BYTES)
#define BSP_RAM_SIZE_BYTES (CONFIG_RAM_SIZE_BYTES)
#define BSP_DATA_FLASH_SIZE_BYTES (CONFIG_DATAFLASH_SIZE_BYTES)

#if defined(CONFIG_PACKAGE_LQFP)
    #define BSP_PACKAGE_LQFP
#endif

#define BSP_PACKAGE_PINS (CONFIG_PACKAGE_PIN_SIZE)
#endif /* BSP_MCU_DEVICE_PN_CFG_H_ */
