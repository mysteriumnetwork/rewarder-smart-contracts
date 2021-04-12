// +build mage

/*
 * Copyright (C) 2021 The "MysteriumNetwork/node" Authors.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package main

import (
	"strings"

	"github.com/magefile/mage/sh"
	"github.com/rs/zerolog/log"
)

// Test runs the tests in a docker container.
func Test() error {
	err := sh.RunV("docker", "build", "-t", "rewarder-smart-contracts_rsc:latest", ".")
	if err != nil {
		log.Info().Err(err).Msg("Could build rewarder image")
		return err
	}
	err = sh.RunV("docker", strings.Split("run rewarder-smart-contracts_rsc npm run test", " ")...)
	if err != nil {
		log.Info().Msg("Tests failed.")
		return err
	}
	log.Info().Msg("Tests succeeded!")
	return nil
}
