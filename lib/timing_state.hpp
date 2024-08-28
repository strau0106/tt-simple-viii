#ifndef LIB_TIMING_STATE_HPP
#define LIB_TIMING_STATE_HPP

#include <cpu_control.h>
#include <control_word.hpp>

class TimingState {
   private:
    ControlWord* control_words[NUMBER_OF_FLAGS];

   public:
    TimingState() {
        for (int i = 0; i < NUMBER_OF_FLAGS; i++) {
            this->control_words[i] = ControlWord().set_next_instr(1);
        }
    }

    TimingState(ControlWord* default_control_word) {
        for (int i = 0; i < NUMBER_OF_FLAGS; i++) {
            this->control_words[i] = default_control_word;
        }
    }
    TimingState* override_control_word_for_flag(cpu_control::alu_flag_e flag,
                                                ControlWord* control_word) {
        this->control_words[flag] = control_word;
        return this;
    }

    const unsigned int* bin() {
        unsigned int* bin = new unsigned int[NUMBER_OF_FLAGS];
        for (int i = 0; i < NUMBER_OF_FLAGS; i++) {
            bin[i] = this->control_words[i]->bin();
        }
        return bin;
    }
};

#endif  // LIB_TIMING_STATE_HPP