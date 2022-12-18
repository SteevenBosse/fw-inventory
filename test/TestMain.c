#include "Main.h"
#include "unity.h"

#include "mock_cs.h"
#include "mock_flash.h"
#include "mock_gpio.h"
#include "mock_interrupt.h"
#include "mock_pcm.h"
#include "mock_queue.h"
#include "mock_task.h"

void setUp(void)
{
}

void tearDown(void)
{
}

void test_Main_NeedTToImplement(void)
{
    FlashCtl_setWaitState_Expect(FLASH_BANK0, 2);
    FlashCtl_setWaitState_Expect(FLASH_BANK1, 2);
    CS_setDCOCenteredFrequency_Expect(CS_DCO_FREQUENCY_3);
    CS_initClockSignal_Expect(CS_HSMCLK, CS_DCOCLK_SELECT, CS_CLOCK_DIVIDER_1);
    CS_initClockSignal_Expect(CS_SMCLK, CS_DCOCLK_SELECT, CS_CLOCK_DIVIDER_1);
    CS_initClockSignal_Expect(CS_MCLK, CS_DCOCLK_SELECT, CS_CLOCK_DIVIDER_1);
    CS_initClockSignal_Expect(CS_ACLK, CS_REFOCLK_SELECT, CS_CLOCK_DIVIDER_1);
    PCM_setCoreVoltageLevel_ExpectAndReturn(PCM_VCORE0, true);
    AppMain();
}
