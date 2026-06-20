# TUXEDO drivers — Linux control for Tongfang/Uniwill/Clevo hardware.
#
# This laptop is a Tongfang GM6PX0X (PCSpecialist "Recoil 16"), the same
# chassis class TUXEDO sells as the Stellaris 16. The rear/vent "light bar" is
# driven by the embedded controller, not the USB ITE 8291 that handles the
# keyboard — so OpenRGB can't reach it. TUXEDO's kernel drivers expose EC-driven
# lighting/fan controls via sysfs (e.g. /sys/class/leds/*) on supported models.
#
# `hardware.tuxedo-drivers.enable` loads the kernel modules.
# `hardware.tuxedo-rs.enable` adds the userspace daemon (`tailord`) + `tailor`
# CLI for controlling lighting/fan profiles on top of those drivers.
#
# NOTE: coverage is per-model. If GM6PX0X's light bar doesn't appear under
# /sys/class/leds after a rebuild, the driver doesn't map it on this board and
# there is no other Linux path — the rear lights may simply not be controllable.
{ ... }:
{
  hardware.tuxedo-drivers.enable = true;
  hardware.tuxedo-rs.enable = true;
}
