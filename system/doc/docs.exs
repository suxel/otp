# %CopyrightBegin%
#
# SPDX-License-Identifier: Apache-2.0
#
# Copyright Ericsson AB 2024-2025. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# %CopyrightEnd%
[
  extras: [
    "README.md",
    "installation_guide/installation_guide.md",
    "installation_guide/INSTALL.md": [source: "../../HOWTO/INSTALL.md"],
    "installation_guide/INSTALL-CROSS.md": [source: "../../HOWTO/INSTALL-CROSS.md"],
    "installation_guide/INSTALL-WIN32.md": [source: "../../HOWTO/INSTALL-WIN32.md"],
    "installation_guide/OTP-PATCH-APPLY.md": [source: "../../HOWTO/INSTALL-PATCH-APPLY.md"],
    "system_principles/system_principles.md": [],
    "system_principles/error_logging.md": [],
    "system_principles/create_target.md": [],
    "system_principles/upgrade.md": [],
    "system_principles/versions.md": [],
    "system_principles/misc.md": [],
    "embedded/embedded.md": [],
    "getting_started/getting_started.md": [],
    "getting_started/seq_prog.md": [],
    "getting_started/conc_prog.md": [],
    "getting_started/robustness.md": [],
    "getting_started/records_macros.md": [],
    "getting_started/howto_debug.md": [],
    "reference_manual/reference_manual.md": [],
    "reference_manual/character_set.md": [],
    "reference_manual/data_types.md": [],
    "reference_manual/patterns.md": [],
    "reference_manual/modules.md": [],
    "reference_manual/documentation.md": [],
    "reference_manual/ref_man_functions.md": [],
    "reference_manual/typespec.md": [],
    "reference_manual/opaques.md": [],
    "reference_manual/nominals.md": [],
    "reference_manual/expressions.md": [],
    "reference_manual/macros.md": [],
    "reference_manual/ref_man_records.md": [],
    "reference_manual/errors.md": [],
    "reference_manual/features.md": [],
    "reference_manual/ref_man_processes.md": [],
    "reference_manual/distributed.md": [],
    "reference_manual/code_loading.md": [],
    "reference_manual/ports.md": [],
    "programming_examples/programming_examples.md": [],
    "programming_examples/prog_ex_records.md": [],
    "programming_examples/funs.md": [],
    "programming_examples/list_comprehensions.md": [],
    "programming_examples/bit_syntax.md": [],
    "efficiency_guide/efficiency_guide.md": [],
    "efficiency_guide/commoncaveats.md": [],
    "efficiency_guide/binaryhandling.md": [],
    "efficiency_guide/maps.md": [],
    "efficiency_guide/listhandling.md": [],
    "efficiency_guide/eff_guide_functions.md": [],
    "efficiency_guide/tablesdatabases.md": [],
    "efficiency_guide/eff_guide_processes.md": [],
    "efficiency_guide/drivers.md": [],
    "efficiency_guide/memory.md": [],
    "efficiency_guide/system_limits.md": [],
    "efficiency_guide/profiling.md": [],
    "efficiency_guide/benchmarking.md": [],
    "tutorial/tutorial.md": [],
    "tutorial/overview.md": [],
    "tutorial/example.md": [],
    "tutorial/c_port.md": [],
    "tutorial/erl_interface.md": [],
    "tutorial/c_portdriver.md": [],
    "tutorial/cnode.md": [],
    "tutorial/nif.md": [],
    "tutorial/debugging.md": [],
    "design_principles/design_principles.md": [],
    "design_principles/gen_server_concepts.md": [],
    "design_principles/statem.md": [],
    "design_principles/events.md": [],
    "design_principles/sup_princ.md": [],
    "design_principles/spec_proc.md": [],
    "design_principles/applications.md": [],
    "design_principles/included_applications.md": [],
    "design_principles/distributed_applications.md": [],
    "design_principles/release_structure.md": [],
    "design_principles/release_handling.md": [],
    "design_principles/appup_cookbook.md": []
  ],
  main: "readme",
  api_reference: false,
  skip_code_autolink_to: ["erts_debug:size/1", "erts_debug:flat_size/1"],
  groups_for_extras:
    File.read!("guides")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn guide ->
      [name, title] = String.split(guide, ":")
      {title, ~r/#{name}/}
    end)
]
