#!/bin/bash

title="Test Script"

steps=(
    "Step 1"
    "Step 2"
    "Step 3"
)

source multistep.sh

__display_steps

__start_step
echo Sub-task 1
sleep 1
echo Sub-task 2
sleep 1
echo Sub-task 3
sleep 1
__step_success

__start_step
echo Sub-task 1
sleep 1
echo Sub-task 2
sleep 1
echo Sub-task 3
sleep 1
__step_success

__start_step
echo Sub-task 1
sleep 1
echo Sub-task 2
sleep 1
echo Sub-task 3
sleep 1
__step_success

__reset_scrolling
