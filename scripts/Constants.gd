extends Node

const SQRT2 = sqrt(2)
const SQRTHALF = sqrt(0.5)

# Constraints of the cursor effectiveness
const CURSOR_RANGE = Rect2(40 + 5, 20 + 2.5, 1440 - 10, 1060 - 5)

enum ACTION {IDLE, WALKING, RUNNING, SHOOTING}

enum ENEMY_ACTION {WALK, RUN, SHOOT, CROUCH, UNCROUCH}
