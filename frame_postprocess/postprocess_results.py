from .base import *


def plot_building_at_t(t, edp, columns, beams, plot_scale, column_list, beam_list, ax, x_gap=380, y_gap=500):
    # Take LineCollections objects of the columns and beams and plots them including the displacements at
    # a given time t
    #
    # INPUTS
    #    t           = index for deformed shape plot
    #    edp         = 2D np.array [floor_i, time] of the displacement of each floor
    #               or 3D np.array [floor_i, axis_i, time] of the displacement of each panel zone
    #    columns     = LineCollection of columns
    #    beams       = LineCollections of beams
    #    plot_scale  = scale for amplifying displacements
    #    column_list = 2D np.array [stories, pier lines]
    #    beam_list   = 2D np.array [floors, bays]
    #    ax          = axes to plot in

    ax.cla()

    [n_columns, _, _] = columns.shape
    [n_beams, _, _] = beams.shape
    n_stories = int(n_columns - n_beams)
    n_bays = int(n_beams / n_stories)

    columns_t = columns.copy()
    beams_t = beams.copy()

    if edp.ndim == 3:
        ### For disp on each column axis ###

        # Add disp to the ground nodes (if not already in edp matrix)
        [n_disps, n_piers, n_pts] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((n_piers, n_pts)), axis=0)

        # Add the displacement of the floor to each column and beam
        for i_end in range(2):
            i_col = 0
            for i_story in range(n_stories):
                for i_pier in range(n_piers):
                    if column_list[i_story, i_pier] == 1:
                        columns_t[i_col, i_end, 0] = columns[i_col, i_end, 0] + \
                                                     plot_scale * edp[i_story + i_end, i_pier, t]
                        i_col += 1
        for i_end in range(2):
            i_beam = 0
            for i_story in range(n_stories):
                for i_bay in range(n_bays):
                    if beam_list[i_story, i_bay] == 1:
                        if beam_list[i_story, i_bay] == 1:
                            beams_t[i_beam, i_end, 0] = beams[i_beam, i_end, 0] + \
                                                        plot_scale * edp[i_story + 1, i_bay + i_end, t]
                            i_beam += 1

    elif edp.ndim == 2:
        ### For disp on each column axis and no time response ###

        # Add disp to the ground nodes (if not already in edp matrix)
        [n_disps, n_piers] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((1, n_piers)), axis=0)

        # Add the displacement of the floor to each column and beam
        for i_end in range(2):
            i_col = 0
            for i_story in range(n_stories):
                for i_pier in range(n_piers):
                    if column_list[i_story, i_pier] == 1:
                        columns_t[i_col, i_end, 0] = columns[i_col, i_end, 0] + \
                                                     plot_scale * edp[i_story + i_end, i_pier]
                        i_col += 1
        for i_end in range(2):
            i_beam = 0
            for i_story in range(n_stories):
                for i_bay in range(n_bays):
                    if beam_list[i_story, i_bay] == 1:
                        beams_t[i_beam, i_end, 0] = beams[i_beam, i_end, 0] + \
                                                    plot_scale * edp[i_story + 1, i_bay + i_end]
                        i_beam += 1

    else:
        ### For one disp input per floor ###

        # Add disp to the ground nodes (if not already in edp matrix)
        [n_disps, n_pts] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((1, n_pts)), axis=0)

        # Get number of columns per story and beams per floor
        columns_story = np.sum(column_list, axis=1)
        beams_floor = np.sum(beam_list, axis=1)

        # Add the displacement of the floor to each column and beam
        i_col = 0
        i_beam = 0
        for i_story in range(n_stories):
            for i_end in range(2):
                columns_t[i_col:int(i_col + columns_story[i_story] + 1), i_end, 0] = columns[i_col:int(i_col + columns_story[i_story] + 1), i_end, 0] + \
                                                                                     plot_scale * edp[i_story + i_end, t]
            i_col = int(i_col + columns_story[i_story])

            beams_t[i_beam:int(i_beam + beams_floor[i_story] + 1), :, 0] = beams[i_beam:int(i_beam + beams_floor[i_story] + 1), :, 0] + \
                                                                           plot_scale * edp[i_story + 1, t]
            i_beam = int(i_beam + beams_floor[i_story])

    column_collection = LineCollection(columns, color='darkgray', linestyle='-', linewidths=1)
    _ = ax.add_collection(column_collection)

    beam_collection = LineCollection(beams, color='darkgray', linestyle='-', linewidths=1)
    _ = ax.add_collection(beam_collection)

    column_collection = LineCollection(columns_t, color='k', linestyle='-', linewidths=1)
    _ = ax.add_collection(column_collection)

    beam_collection = LineCollection(beams_t, color='k', linestyle='-', linewidths=1)
    _ = ax.add_collection(beam_collection)

    _ = ax.axis('scaled')

    building_height = np.max(columns[:, :, 1])
    building_width = np.max(columns[:, :, 0])

    _ = ax.set_xlim(-x_gap, building_width + x_gap)
    _ = ax.set_ylim(-y_gap, building_height + y_gap / 5)
    _ = ax.axis('off')
    # _ = ax.text(building_width / 2, -y_gap, 'Displacement scale: ' + str(plot_scale) + 'x', ha='center', va='top',
    #             fontsize=18)


def get_coordinates(beam_list, column_list, bay_widths, story_heights):

    ####### Read building information from MATLAB file #######
    #     model_data = h5py.File('generate model/' + bldg_name + '.mat')

    # Geometry
    (n_stories, n_bays) = beam_list.shape

    ####### store the original geometry of each beam, column, and joint #######
    # store the original geometry of each column
    columns = np.zeros(((n_bays + 1) * n_stories, 2, 2))
    i_element = 0
    for i_story in range(n_stories):

        for i_beam in range(n_bays + 1):

            if column_list[i_story, i_beam] > 0:

                # x values of columns
                columns[i_element, :, 0] = np.sum(bay_widths[:i_beam])
                for i_end in range(2):
                    # y values of columns
                    columns[i_element, i_end, 1] = np.sum(story_heights[:i_story + i_end])
                i_element = i_element + 1

    # store the original geometry of each beam
    beams = np.zeros((n_bays * n_stories, 2, 2))
    i_element = 0
    for i_story in range(n_stories):

        for i_beam in range(n_bays):

            if beam_list[i_story, i_beam] > 0:

                # y values of beams
                beams[i_element, :, 1] = np.sum(story_heights[:i_story + 1])
                for i_end in range(2):
                    # x values of beams
                    if (beam_list[i_story, min(i_beam+1, n_bays-1)] == 0) and \
                            (column_list[i_story, min(i_beam+1, n_bays)] == 0) and \
                            (column_list[min(i_story+1, n_stories-1), min(i_beam+1, n_bays)] == 0) and (i_end == 1):
                        # for double bay beams
                        beams[i_element, i_end, 0] = np.sum(bay_widths[:i_beam + i_end + 1])
                    else:
                        # for typical single bay beams
                        beams[i_element, i_end, 0] = np.sum(bay_widths[:i_beam + i_end])
                i_element = i_element + 1

    # store the original geometry of each joint
    joints_x = np.array([np.sum(bay_widths[:i_beam]) for i_beam in range(n_bays + 1)])
    joints_y = np.array([np.sum(story_heights[:i_story + 1]) for i_story in range(n_stories)])
    joints_y = np.insert(joints_y, 0, 0, axis=0)  # add the hinge at column base
    [joints_x, joints_y] = np.meshgrid(joints_x, joints_y)

    # Adjust joint_x coordinate if has beams spanning two bays
    for i_story in range(n_stories):
        i_floor = i_story + 1
        for i_beam in range(n_bays):
            if (beam_list[i_story, min(i_beam+1, n_bays-1)] == 0) and \
                    (column_list[i_story, min(i_beam+1, n_bays)] == 0) and \
                    (column_list[min(i_story+1, n_stories-1), min(i_beam+1, n_bays)] == 0) and (i_end == 1):
                joints_x[i_floor, i_beam + 1] = joints_x[i_floor, i_beam + 2]

    return n_stories, n_bays, columns, beams, joints_x, joints_y


def plot_flaw_size(ax, joints_x, joints_y, a0, side):

    # Retrieve basic info for loops
    n_stories, n_bays = joints_x.shape
    n_stories = n_stories - 1
    n_bays = n_bays - 1

    joints_x_low = np.empty((0, 1))
    joints_y_low = np.empty((0, 1))
    joints_x_med = np.empty((0, 1))
    joints_y_med = np.empty((0, 1))
    joints_x_large = np.empty((0, 1))
    joints_y_large = np.empty((0, 1))

    for story_i in range(n_stories):

        for bay_i in range(n_bays):

            if side == 'left':
                col_i = bay_i
                d_x = 30
            else:
                col_i = bay_i + 1
                d_x = -30

            if a0[bay_i, story_i] < 0.1:
                joints_x_low = np.append(joints_x_low, joints_x[story_i + 1, col_i] + d_x)
                joints_y_low = np.append(joints_y_low, joints_y[story_i + 1, col_i])
            elif a0[bay_i, story_i] < 0.2:
                joints_x_med = np.append(joints_x_med, joints_x[story_i + 1, col_i] + d_x)
                joints_y_med = np.append(joints_y_med, joints_y[story_i + 1, col_i])
            else:
                joints_x_large = np.append(joints_x_large, joints_x[story_i + 1, col_i] + d_x)
                joints_y_large = np.append(joints_y_large, joints_y[story_i + 1, col_i])

    _ = ax.plot(joints_x_low, joints_y_low, 'o', color=color_specs[2], alpha=0.8)
    _ = ax.plot(joints_x_med, joints_y_med, 'o', color=color_specs[0], alpha=0.8)
    _ = ax.plot(joints_x_large, joints_y_large, 'o', color=color_specs[1], alpha=0.8)

def get_beam_response(results_folder, beam_list, filenames, res_type='Max', t=0, def_desired='rot'):
    # Read response for beams, currently takes either the maximum or the last of the time history
    #
    # INPUTS
    #    results_folder = path to folder with the results of NLRHA
    #    beam_list      = 2D np.array with 1 or 0 for the beams that exist
    #    filenames      = list with any group of the following alternatives
    #                     'frac_LB'
    #                     'frac_LT'
    #                     'frac_RB'
    #                     'frac_RT'
    #                     'FI_LB'
    #                     'FI_LT'
    #                     'FI_RB'
    #                     'FI_RT'
    #                     'hinge_left': plastic hinge on left end of beam
    #                     'hinge_right': plastic hinge on right end of beam
    #                     'def_left': fracture spring on left end of beam
    #                     'def_right': fracture spring on right end of beam
    #   res_type        = 'Max' : return the maximum response in the time history
    #                     'at_t': return the response at the given time t
    #                     'all_t': return the response history
    #   t               = index for deformed shape plot
    #   def_desired     = 'axial'
    #                     'shear'
    #                     'rot'
    #                     Only applies for hinge_left/right and def_left/right
    #
    # OUTPUTS
    #    beam_results = dictionary with all results for the beams, one key for each filename
    #

    beam_results = dict(keys=filenames)

    n_stories, n_bays = beam_list.shape
    num_beams = np.sum(beam_list)

    # Read results as 1d array
    for file in filenames:
        filepath = posixpath.join(results_folder, file + '.out')
        
        data_1d = np.loadtxt(filepath)
        if data_1d.ndim == 1:
            n_cols = 1
        else:
            _, n_cols = data_1d.shape
        
        if n_cols == 6*num_beams: #file == 'hinge_left' or file == 'hinge_right':
            # read axial def, shear def, rotation for each hinge
            axial_def = data_1d[:, 0:n_cols:6]
            shear_def = data_1d[:, 1:n_cols:6]
            rot = data_1d[:, 2:n_cols:6]

            if def_desired == 'axial':
                res = axial_def
            elif def_desired == 'shear':
                res = shear_def
            else:
                res = rot

            if res_type == 'Max':
                # read maximum response for each hinge
                results_1d = np.max(abs(res), axis=0)
            elif res_type == 'at_t':
                # read response at index t for each hinge
                aux = abs(res)
                results_1d = aux[t]
            else:
                # read response history
                results_1d = res        
        
        elif n_cols == 3*num_beams: #file == 'hinge_left' or file == 'hinge_right':
            # read axial def, shear def, rotation for each hinge
            axial_def = data_1d[:, 0:n_cols:3]
            shear_def = data_1d[:, 1:n_cols:3]
            rot = data_1d[:, 2:n_cols:3]

            if def_desired == 'axial':
                res = axial_def
            elif def_desired == 'shear':
                res = shear_def
            else:
                res = rot

            if res_type == 'Max':
                # read maximum response for each hinge
                results_1d = np.max(abs(res), axis=0)
            elif res_type == 'at_t':
                # read response at index t for each hinge
                aux = abs(res)
                results_1d = aux[t]
            else:
                # read response history
                results_1d = res

        elif n_cols == num_beams:
            if res_type == 'Max' or 'env' in file:
                # read the maximum response value in entire time history
                results_1d = np.max(abs(data_1d), axis=0)
            elif res_type == 'at_t':
                # read rotation at index t for each hinge
                aux = abs(data_1d)
                results_1d = aux[t]
            else:
                # read response history
                results_1d = data_1d
        else:
            print('ERROR: output not consistent with number of beams')
            print(file)
            print('n_cols = ' + str(n_cols) + '; num_beams = ' + str(num_beams))

        # Initialize final matrix to return the results
        if res_type == 'all_t':
            if results_1d.ndim == 1:
                n_pts = len(results_1d)
            else:
                n_pts, _ = results_1d.shape
            beam_results[file] = np.zeros([n_stories, n_bays, n_pts])
        else:
            beam_results[file] = np.zeros([n_stories, n_bays])

        # Save in desired format
        i_element = 0
        for i_story in range(n_stories):
            for i_beam in range(n_bays):
                if beam_list[i_story, i_beam] > 0:
                    if res_type == 'all_t':
                        if results_1d.ndim == 1:
                            beam_results[file][i_story, i_beam, :] = results_1d
                        else:
                            beam_results[file][i_story, i_beam, :] = results_1d[:, i_element]
                    else:
                        if results_1d.ndim == 0:
                            beam_results[file][i_story, i_beam] = results_1d
                        else:
                            beam_results[file][i_story, i_beam] = results_1d[i_element]
                    i_element += 1

    return beam_results


def get_pz_response(results_folder, beam_list, column_list, filenames, res_type='Max', t=0):
    # Read response for panel zones, currently takes the maximum of the time history
    #
    # INPUTS
    #    results_folder = path to folder with the results of NLRHA
    #    beam_list      = 2D np.array with 1 or 0 for the beams that exist
    #    column_list    = 2D np.array with 1 or 0 for the columns that exist
    #    filenames      = list with any group of the following alternatives
    #                     'pz_rot'
    #                     'all_disp': include time vector
    #    res_type       = 'Max' : return the maximum response in the time history
    #                     'at_t': return the response at the given time t
    #                     'all_t': return the response history
    #    t              = index for deformed shape plot
    #
    # OUTPUTS
    #    pz_results = dictionary with all results for the panel zones
    #

    pz_results = dict(keys=filenames)
    n_stories, n_pier = column_list.shape

    # Read results as 1d array
    for file in filenames:
        filepath = posixpath.join(results_folder, file + '.out')

        res = np.loadtxt(filepath)  # read response history
        # Format results
        if file == 'all_disp':
            # Remove time column
            pz_results['time'] = res[:, 0]
            res = res[:, 1:]
        if file == 'pz_rot':
            # take absolute
            res = abs(res)

        # Read requested data
        if res_type == 'Max':
            # read maximum response for each pz
            results_1d = np.max(res, axis=0)
        elif res_type == 'at_t':
            # read response at index t for each pz
            results_1d = aux[t]
        else:
            results_1d = res

        # Initialize final matrix to return the results
        if res_type == 'all_t':
            n_pts, _ = results_1d.shape
            pz_results[file] = np.zeros([n_stories, n_pier, n_pts])
        else:
            pz_results[file] = np.zeros([n_stories, n_pier])

        # Save in desired format
        i_element = 0
        for i_story in range(n_stories):
            for i_pier in range(n_pier):
                if beam_list[i_story, min(i_pier, n_pier - 2)] > 0 and (
                        column_list[i_story, i_pier] > 0 or column_list[i_story + 1, i_pier] > 0):

                    if res_type == 'all_t':
                        pz_results[file][i_story, i_pier, :] = results_1d[:, i_element]
                    else:
                        pz_results[file][i_story, i_pier] = results_1d[i_element]
                    i_element += 1

    return pz_results


def get_column_response(results_folder, beam_list, column_list, filenames, res_type='Max', t=0, def_desired='rot'):
    # Read response for columns, currently takes the maximum of the time history
    #
    # INPUTS
    #    results_folder = path to folder with the results of NLRHA
    #    beam_list      = 2D np.array with 1 or 0 for the beams that exist
    #    column_list    = 2D np.array with 1 or 0 for the columns that exist
    #    filenames      = list with any group of the following alternatives
    #                     'hinge_bot'
    #                     'hinge_top'
    #    res_type       = 'Max' : return the maximum response in the time history
    #                     'at_t': return the response at the given time t
    #                     'all_t': return the response history
    #    t              = index for deformed shape plot
    #   def_desired     = 'axial'
    #                     'shear'
    #                     'rot'
    #                     Only applies for hinge_left/right and def_left/right
    #
    # OUTPUTS
    #    column_results = dictionary with all results for the columns, one key for each filename
    #

    column_results = dict(keys=filenames)

    n_stories, n_pier = column_list.shape
    num_columns = np.sum(column_list)

    # Read results as 1d array
    for file in filenames:
        filepath = posixpath.join(results_folder, file + '.out')
        
        data_1d = np.loadtxt(filepath)
        _, n_cols = data_1d.shape

        if n_cols == int(3*num_columns):
            # read axial def, shear def, rotation for each hinge
            axial_def = data_1d[:, 0:n_cols:3]
            shear_def = data_1d[:, 1:n_cols:3]
            rot = data_1d[:, 2:n_cols:3]

            if def_desired == 'axial':
                res = axial_def
            elif def_desired == 'shear':
                res = shear_def
            else:
                res = rot

            if res_type == 'Max':
                # read maximum response for each hinge
                results_1d = np.max(abs(res), axis=0)
            elif res_type == 'at_t':
                # read response at index t for each hinge
                aux = abs(res)
                results_1d = aux[t]
            else:
                # read response history
                results_1d = res

        elif n_cols == int(6*num_columns):
            # read moment for each hinge
            M_bot = data_1d[:, 2:n_cols:6]
            M_top = data_1d[:, 5:n_cols:6]

            if res_type == 'Max':
                # read maximum response for each hinge
                if 'bot' in file:
                    results_1d = np.max(abs(M_bot), axis=0)
                elif 'top' in file:
                    results_1d = np.max(abs(M_top), axis=0)
            elif res_type == 'at_t':
                # read response at index t for each hinge
                if 'bot' in file:
                    aux = abs(M_bot)
                elif 'top' in file:
                    aux = abs(M_top)
                results_1d = aux[t]
            else:
                # read response history
                if 'bot' in file:
                    results_1d = M_bot
                elif 'top' in file:
                    results_1d = M_top

        elif n_cols == num_columns:
            if res_type == 'Max' or 'env' in file:
                # read the maximum response value in entire time history
                results_1d = np.max(abs(data_1d), axis=0)
            elif res_type == 'at_t':
                # read response at index t for each hinge
                aux = abs(data_1d)
                results_1d = aux[t]
            else:
                # read response history
                results_1d = data_1d
        else:
            print('ERROR: output not consistent with number of columns')
            print(file)
            print('n_cols = ' + str(n_cols) + '; num_columns = ' + str(num_columns))

        # Initialize final matrix to return the results
        if res_type == 'all_t':
            n_pts, _ = results_1d.shape
            column_results[file] = np.zeros([n_stories, n_pier, n_pts])
        else:
            column_results[file] = np.zeros([n_stories, n_pier])

        # Save in desired format
        i_element = 0
        for i_pier in range(n_pier):
            for i_story in range(n_stories):
                if column_list[i_story, i_pier] > 0:  # jump if setbacks
                    if i_story == 0 or beam_list[i_story - 1, min(i_pier, n_pier - 2)]:  # jump columns already created in atriums
                        if res_type == 'all_t':
                            column_results[file][i_story, i_pier, :] = results_1d[:, i_element]
                        else:
                            column_results[file][i_story, i_pier] = results_1d[i_element]

                        i_element += 1

    return column_results



def get_story_response(results_folder, beam_list, filenames):
    # INPUTS
    #    results_folder = path to folder with the results of NLRHA
    #    beam_list      = 2D np.array with 1 or 0 for the beams that exist
    #    filenames      = list with any group of the following alternatives
    #                     'disp': only this one has a time column
    #                     'drift'
    #                     'drift_env'
    #                     'acc_env'
    #
    # OUTPUTS
    #    story_response = dictionary with all results, one key for each filename
    #

    n_stories, _ = beam_list.shape

    story_response = dict(keys=filenames)

    # Read results as 1d array
    for file in filenames:
        # Collect results for first story
        if file == 'drift_max':
            filepath = posixpath.join(results_folder, 'story' + str(1) + '_drift.out')
        else:
            filepath = posixpath.join(results_folder, 'story' + str(1) + '_' + file + '.out')
        try:
            response = np.loadtxt(filepath)
        except:
            print('ERROR IN FILE ' + filepath)
            return

        if file == 'drift_max':
            response = np.max(np.abs(response[:, 1]))  # remove time column

        if file == 'drift':
            response = response[:, 1]  # remove time column

        if file == 'disp':
            story_response['time'] = response[:, 0]
            response = response[:, 1]

        elif file == 'drift_env' or file == 'acc_env':
            response = response[2]

        # Collect results for all other stories
        for i_story in range(n_stories - 1):
            i_story = i_story + 1
            if file == 'drift_max':
                filepath = posixpath.join(results_folder, 'story' + str(i_story + 1) + '_drift.out')
            else:
                filepath = posixpath.join(results_folder, 'story' + str(i_story + 1) + '_' + file + '.out')
            # print(filepath)

            try:
                res = np.loadtxt(filepath)
            except:
                print('ERROR IN FILE ' + filepath)
                return

            if file == 'disp' or file == 'drift':
                res = res[:, 1]

                # Make sure all time histories have same length as first story
                n_pts = len(response.T)
                if len(res) < n_pts:
                    aux = np.zeros(n_pts)
                    aux[:len(res)] = res.flatten()
                    res = aux
                elif len(res) > n_pts:
                    res = res[:n_pts]

            elif file == 'drift_max':
                res = np.max(np.abs(res[:, 1]))
            elif file == 'drift_env' or file == 'acc_env':
                res = res[2]

            response = np.vstack((response, res))

        story_response[file] = response

    return story_response


def get_splice_response(results_folder, splice_list, beam_list, column_list, filenames, res_type='Max', t=0,
                        def_desired='rot'):
    # Read response for columns, currently takes the maximum of the time history
    #
    # INPUTS
    #    results_folder   = path to folder with the results of NLRHA
    #    splice_list      = 2D np.array with 1 or 0 for the beams that exist
    #    beam_list        = 2D np.array with 1 or 0 for the beams that exist
    #    column_list      = 2D np.array with 1 or 0 for the columns that exist
    #    filenames        = list with any group of the following alternatives
    #                       'ss_splice'
    #    res_type         = 'Max' : return the maximum response in the time history
    #                       'at_t': return the response at the given time t
    #                       'all_t': return the response history
    #    t                = index for deformed shape plot
    #   def_desired       = 'axial'
    #                       'shear'
    #                       'rot'
    #                       'strain'
    #                       'stress'
    #                       Only applies for hinge_left/right and def_left/right
    #
    # OUTPUTS
    #    column_results   = dictionary with all results for the columns, one key for each filename
    #

    column_results = dict(keys=filenames)

    n_stories, n_pier = column_list.shape
    # splice_list = np.zeros([n_stories, n_pier])
    # splice_list[n_stories_splice-1 : n_stories:n_stories_splice] = np.ones([n_pier])
    num_splices = np.sum(splice_list)

    # Read results as 1d array
    for file in filenames:
        filepath = posixpath.join(results_folder, file + '.out')

        data_1d = np.loadtxt(filepath)
        _, n_cols = data_1d.shape

        if n_cols == int(2 * num_splices):
            # read stress and strain for a unique section
            stress = data_1d[:, 0:n_cols:2]
            strain = data_1d[:, 1:n_cols:2]

            if def_desired == 'stress':
                res = stress
            elif def_desired == 'strain':
                res = strain
            else:
                print('ERROR: specify either "stress" or "strain" output')

            if res_type == 'Max':
                # read maximum response for each hinge
                results_1d = np.max(abs(res), axis=0)
            elif res_type == 'at_t':
                # read response at index t for each hinge
                aux = abs(res)
                results_1d = aux[t]
            else:
                # read response history
                results_1d = res

        elif n_cols == int(10 * num_splices):
            # read stress and strain for a unique section from results on all (5) section of the forceBasedElement
            stress = data_1d[:, 4:n_cols:10]
            strain = data_1d[:, 5:n_cols:10]

            if def_desired == 'stress':
                res = stress
            elif def_desired == 'strain':
                res = strain
            else:
                print('ERROR: specify either "stress" or "strain" output')

            if res_type == 'Max':
                # read maximum response for each hinge
                results_1d = np.max(abs(res), axis=0)
            elif res_type == 'at_t':
                # read response at index t for each hinge
                aux = abs(res)
                results_1d = aux[t]
            else:
                # read response history
                results_1d = res

        elif n_cols == int(3 * num_splices):
            # read axial def, shear def, rotation for each hinge
            axial_def = data_1d[:, 0:n_cols:3]
            shear_def = data_1d[:, 1:n_cols:3]
            rot = data_1d[:, 2:n_cols:3]

            if def_desired == 'axial':
                res = axial_def
            elif def_desired == 'shear':
                res = shear_def
            else:
                res = rot

            if res_type == 'Max':
                # read maximum response for each hinge
                results_1d = np.max(abs(res), axis=0)
            elif res_type == 'at_t':
                # read response at index t for each hinge
                aux = abs(res)
                results_1d = aux[t]
            else:
                # read response history
                results_1d = res

        elif n_cols == int(6 * num_splices):
            # read moment for each hinge
            M_bot = data_1d[:, 2:n_cols:6]
            M_top = data_1d[:, 5:n_cols:6]

            if res_type == 'Max':
                # read maximum response for each hinge
                if 'bot' in file:
                    results_1d = np.max(abs(M_bot), axis=0)
                elif 'top' in file:
                    results_1d = np.max(abs(M_top), axis=0)
            elif res_type == 'at_t':
                # read response at index t for each hinge
                if 'bot' in file:
                    aux = abs(M_bot)
                elif 'top' in file:
                    aux = abs(M_top)
                results_1d = aux[t]
            else:
                # read response history
                if 'bot' in file:
                    aux = M_bot
                elif 'top' in file:
                    aux = M_top

        elif n_cols == num_splices:
            if res_type == 'Max' or 'env' in file:
                # read the maximum response value in entire time history
                results_1d = np.max(abs(data_1d), axis=0)
            elif res_type == 'at_t':
                # read response at index t for each hinge
                aux = abs(data_1d)
                results_1d = aux[t]
            else:
                # read response history
                results_1d = data_1d
        else:
            print('ERROR: output not consistent with number of columns')
            print(file)
            print('n_cols = ' + str(n_cols) + '; num_splices = ' + str(num_splices))

        # Initialize final matrix to return the results
        if res_type == 'all_t':
            n_pts, _ = results_1d.shape
            column_results[file] = np.zeros([n_stories, n_pier, n_pts])
        else:
            column_results[file] = np.zeros([n_stories, n_pier])

        # Save in desired format
        i_element = 0
        for i_pier in range(n_pier):
            for i_story in range(n_stories):
                if column_list[i_story, i_pier] > 0:  # jump if setbacks
                    if i_story == 0 or beam_list[
                        i_story - 1, min(i_pier, n_pier - 2)]:  # jump columns already created in atriums
                        if splice_list[i_story, i_pier] > 0:  # jump if no splice in this story
                            if res_type == 'all_t':
                                column_results[file][i_story, i_pier, :] = results_1d[:, i_element]
                            else:
                                column_results[file][i_story, i_pier] = results_1d[i_element]

                            i_element += 1

    return column_results


def plot_fractures(ax, joints_x, joints_y, frac_results, marker_size=50, add_legend=False, one_fracture_color='m',
                   both_fractures_color='r'):


    # Retrieve basic info for loops
    n_stories, n_bays = joints_x.shape
    n_stories = n_stories - 1
    n_bays = n_bays - 1

    joints_x_bot = np.empty((0, 1))
    joints_y_bot = np.empty((0, 1))
    joints_x_top = np.empty((0, 1))
    joints_y_top = np.empty((0, 1))
    joints_x_both = np.empty((0, 1))
    joints_y_both = np.empty((0, 1))

    # get matrix of fracture results
    fracture_left = frac_results['frac_LB'] + frac_results['frac_LT'] * 2
    fracture_right = frac_results['frac_RB'] + frac_results['frac_RT'] * 2

    # Review left side of all beams
    for story_i in range(n_stories):

        for bay_i in range(n_bays):

            col_i = bay_i
            d_x = 30

            if fracture_left[story_i, bay_i] == 1:
                # Fracture bottom flage only
                joints_x_bot = np.append(joints_x_bot, joints_x[story_i + 1, col_i] + d_x)
                joints_y_bot = np.append(joints_y_bot, joints_y[story_i + 1, col_i])
            elif fracture_left[story_i, bay_i] == 2:
                # Fracture top flage only
                joints_x_top = np.append(joints_x_top, joints_x[story_i + 1, col_i] + d_x)
                joints_y_top = np.append(joints_y_top, joints_y[story_i + 1, col_i])
            elif fracture_left[story_i, bay_i] == 3:
                # Fracture both flanges
                joints_x_both = np.append(joints_x_both, joints_x[story_i + 1, col_i] + d_x)
                joints_y_both = np.append(joints_y_both, joints_y[story_i + 1, col_i])

    # Review right side of all beams
    for story_i in range(n_stories):

        for bay_i in range(n_bays):

            col_i = bay_i + 1
            d_x = -30

            if fracture_right[story_i, bay_i] == 1:
                # Fracture bottom flage only
                joints_x_bot = np.append(joints_x_bot, joints_x[story_i + 1, col_i] + d_x)
                joints_y_bot = np.append(joints_y_bot, joints_y[story_i + 1, col_i])
            elif fracture_right[story_i, bay_i] == 2:
                # Fracture top flage only
                joints_x_top = np.append(joints_x_top, joints_x[story_i + 1, col_i] + d_x)
                joints_y_top = np.append(joints_y_top, joints_y[story_i + 1, col_i])
            elif fracture_right[story_i, bay_i] == 3:
                # Fracture both flanges
                joints_x_both = np.append(joints_x_both, joints_x[story_i + 1, col_i] + d_x)
                joints_y_both = np.append(joints_y_both, joints_y[story_i + 1, col_i])

    _ = ax.scatter(joints_x_bot, joints_y_bot, s=marker_size, color=one_fracture_color)
    _ = ax.scatter(joints_x_both, joints_y_both, s=marker_size, color=both_fractures_color)
    _ = ax.scatter(joints_x_top, joints_y_top, s=marker_size, color='tab:blue')

    # Plot annotations below the frame to show scale for all non-zero bins
    if add_legend:
        y_gap = -100
        y_between = -150
        _ = ax.scatter(joints_x[0,0] * 1/5, y_gap, s=marker_size, color='m')
        _ = ax.text(joints_x[0,0] * 1/5 + marker_size/4, y_gap - 50, 'Bottom fracture', size=18)

        _ = ax.scatter(joints_x[0,0] * 1/5, y_gap+y_between, s=marker_size, color='r')
        _ = ax.text(joints_x[0,0] * 1/5 + marker_size/4, y_gap - 50 + y_between, 'Top & Bottom fracture', size=18)


def plot_fractures_edp(ax, t, edp, joints_x, joints_y, frac_results, plot_scale=1, marker_size=50, add_legend=False,
                       one_fracture_color='m',
                       both_fractures_color='r'):
    # Retrieve basic info for loops
    n_stories, n_bays = joints_x.shape
    n_stories = n_stories - 1
    n_bays = n_bays - 1

    joints_x_bot = np.empty((0, 1))
    joints_y_bot = np.empty((0, 1))
    joints_x_top = np.empty((0, 1))
    joints_y_top = np.empty((0, 1))
    joints_x_both = np.empty((0, 1))
    joints_y_both = np.empty((0, 1))

    if edp.ndim == 3:
        ### For disp on each column axis ###

        # Add disp to the ground nodes (if not already in edp matrix)
        [n_disps, n_piers, n_pts] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((n_piers, n_pts)), axis=0)

        # Add displacement to each joint index
        joints_x_t = joints_x.copy()
        joints_x_t = joints_x_t + plot_scale * edp[:, :, t]

    elif edp.ndim == 2:
        ### For disp on each column axis ###

        # Add disp to the ground nodes (if not already in edp matrix)
        [n_disps, n_piers] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((1, n_piers)), axis=0)

        # Add displacement to each joint index
        joints_x_t = joints_x.copy()
        joints_x_t = joints_x_t + plot_scale * edp[:, :]

    else:
        ### For one disp input per floor ###

        # Add the ground level displacement
        [n_disps, n_pts] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((1, n_pts)), axis=0)

        # Add displacement to each joint index
        joints_x_t = joints_x.copy()
        for story_i in range(n_stories + 1):  # +1 because starts from the ground
            joints_x_t[story_i, :] = joints_x_t[story_i, :] + plot_scale * edp[story_i, t] * np.ones(
                len(joints_x_t[story_i, :]))

    # get matrix of fracture results
    if frac_results['frac_LB'].ndim == 3 and frac_results['frac_LT'].ndim == 3 and \
            frac_results['frac_RB'].ndim == 3 and frac_results['frac_RT'].ndim == 3:
        ### response history given ###
        frac_results_t = {}
        frac_results_t['frac_LB'] = frac_results['frac_LB'][:,:,t]
        frac_results_t['frac_RB'] = frac_results['frac_RB'][:,:,t]
        frac_results_t['frac_LT'] = frac_results['frac_LT'][:,:,t]
        frac_results_t['frac_RT'] = frac_results['frac_RT'][:,:,t]

        fracture_left = frac_results_t['frac_LB'] + frac_results_t['frac_LT'] * 2
        fracture_right = frac_results_t['frac_RB'] + frac_results_t['frac_RT'] * 2
    elif frac_results['frac_LB'].ndim == 2 and frac_results['frac_LT'].ndim == 2 and \
            frac_results['frac_RB'].ndim == 2 and frac_results['frac_RT'].ndim == 2:
        ### snapshot of the response given ###
        fracture_left = frac_results['frac_LB'] + frac_results['frac_LT'] * 2
        fracture_right = frac_results['frac_RB'] + frac_results['frac_RT'] * 2
    else:
        print('ERROR: non consistent inputs of response to plot')
        return

    # Review left side of all beams
    for story_i in range(n_stories):

        for bay_i in range(n_bays):

            col_i = bay_i
            d_x = 30

            if fracture_left[story_i, bay_i] == 1:
                # Fracture bottom flage only
                joints_x_bot = np.append(joints_x_bot, joints_x_t[story_i + 1, col_i] + d_x)
                joints_y_bot = np.append(joints_y_bot, joints_y[story_i + 1, col_i])
            elif fracture_left[story_i, bay_i] == 2:
                # Fracture top flage only
                joints_x_top = np.append(joints_x_top, joints_x_t[story_i + 1, col_i] + d_x)
                joints_y_top = np.append(joints_y_top, joints_y[story_i + 1, col_i])
            elif fracture_left[story_i, bay_i] == 3:
                # Fracture both flanges
                joints_x_both = np.append(joints_x_both, joints_x_t[story_i + 1, col_i] + d_x)
                joints_y_both = np.append(joints_y_both, joints_y[story_i + 1, col_i])

    # Review right side of all beams
    for story_i in range(n_stories):

        for bay_i in range(n_bays):

            col_i = bay_i + 1
            d_x = -30

            if fracture_right[story_i, bay_i] == 1:
                # Fracture bottom flage only
                joints_x_bot = np.append(joints_x_bot, joints_x_t[story_i + 1, col_i] + d_x)
                joints_y_bot = np.append(joints_y_bot, joints_y[story_i + 1, col_i])
            elif fracture_right[story_i, bay_i] == 2:
                # Fracture top flage only
                joints_x_top = np.append(joints_x_top, joints_x_t[story_i + 1, col_i] + d_x)
                joints_y_top = np.append(joints_y_top, joints_y[story_i + 1, col_i])
            elif fracture_right[story_i, bay_i] == 3:
                # Fracture both flanges
                joints_x_both = np.append(joints_x_both, joints_x_t[story_i + 1, col_i] + d_x)
                joints_y_both = np.append(joints_y_both, joints_y[story_i + 1, col_i])

    _ = ax.scatter(joints_x_bot, joints_y_bot, s=marker_size, color=one_fracture_color)
    _ = ax.scatter(joints_x_both, joints_y_both, s=marker_size, color=both_fractures_color)
    _ = ax.scatter(joints_x_top, joints_y_top, s=marker_size, color='cyan')

    # Plot annotations below the frame to show scale for all non-zero bins
    if add_legend:
        y_gap = -100
        y_between = -150
        _ = ax.scatter(joints_x_t[0, 0] * 1 / 5, y_gap, s=marker_size, color='m')
        _ = ax.text(joints_x_t[0, 0] * 1 / 5 + marker_size / 4, y_gap - 50, 'Bottom fracture', size=18)

        _ = ax.scatter(joints_x_t[0, 0] * 1 / 5, y_gap + y_between, s=marker_size, color='r')
        _ = ax.text(joints_x_t[0, 0] * 1 / 5 + marker_size / 4, y_gap - 50 + y_between, 'Top & Bottom fracture',
                    size=18)


def plot_beam_response(ax, joints_x, joints_y, respose_left, respose_right, d_x=30, max_value=1,
                       max_marker_size=300):
    # Plots response of any continuous quantity of beam end response as a circle of varying size in the correct location
    # in the building
    #
    # INPUTS
    #     joints_x        = np.array of x coordinates of all beam-to-column joints
    #     joints_y        = np.array of y coordinates of all beam-to-column joints
    #     respose_left    = 2D np.array of the response to be plotted on the left side of beams
    #     respose_left    = 2D np.array of the response to be plotted on the right side of beams
    #     d_x             = offset in x for placing the circle
    #     max_value       = maximum value of the quantity to plot
    #     max_marker_size = maximum size of the marker
    #

    # Retrieve basic info for loops
    n_stories, n_bays = joints_x.shape
    n_stories = n_stories - 1
    n_bays = n_bays - 1

    # Set all values greater than the maximum equal to the maximum
    respose_left_t = respose_left.copy()
    respose_right_t = respose_right.copy()
    respose_left_t[respose_left >= max_value] = max_value
    respose_right_t[respose_right >= max_value] = max_value

    # Review left side of all beams
    for story_i in range(n_stories):

        for bay_i in range(n_bays):
            col_i = bay_i

            marker_size = respose_left_t[story_i, bay_i] / max_value * max_marker_size
            _ = ax.scatter(joints_x[story_i + 1, col_i] + d_x, joints_y[story_i + 1, col_i], s=marker_size,
                           facecolors='none', color='m', alpha=0.9)

            # Review right side of all beams
    d_x = -d_x
    for story_i in range(n_stories):

        for bay_i in range(n_bays):
            col_i = bay_i + 1

            marker_size = respose_right_t[story_i, bay_i] / max_value * max_marker_size
            _ = ax.scatter(joints_x[story_i + 1, col_i] + d_x, joints_y[story_i + 1, col_i], s=marker_size,
                           facecolors='none', color='m', alpha=0.9)

    # Plot annotation below the frame to show scale
    y_gap = -50
    _ = ax.scatter(np.mean(joints_x[0]), y_gap, s=max_marker_size, facecolors='none', color='m', alpha=0.9)
    _ = ax.text(np.mean(joints_x[0]) + max_marker_size / 4, y_gap - 50, 'Size = ' + str(max_value), size=18)


def plot_beam_response_bins(ax, joints_x, joints_y, respose_left, respose_right, d_x=30, max_value=1,
                            max_marker_size=300, labelText='FI', bins=np.array([0, 0.5, 0.75, 0.9]),
                            edgecolor='k', facecolors='none', addLegend=True):
    # Plots response of any continuous quantity of beam end response as a circle of varying size in the correct location
    # in the building. The circle sizes have discrete sizes based on the values in the bin vector
    # The first category has no marker, and the others increase linearly until the maximum size
    #
    # INPUTS
    #     joints_x        = np.array of x coordinates of all beam-to-column joints
    #     joints_y        = np.array of y coordinates of all beam-to-column joints
    #     respose_left    = 2D np.array of the response to be plotted on the left side of beams
    #     respose_left    = 2D np.array of the response to be plotted on the right side of beams
    #     d_x             = offset in x for placing the circle
    #     max_value       = maximum value of the quantity to plot
    #     max_marker_size = maximum size of the marker
    #     bins            = np.array of the limits of the beam response to define bins
    #     edgecolor       = color of the edge of the markers
    #     facecolors      = 'none' open circles
    #                     = color of the fill
    #     addLegend       = 'True' add the legend for the bins
    #

    # Retrieve basic info for loops
    n_stories, n_bays = joints_x.shape
    n_stories = n_stories - 1
    n_bays = n_bays - 1

    # Set all values greater than the maximum equal to the maximum
    respose_left_t = respose_left.copy()
    respose_right_t = respose_right.copy()
    respose_left_t[respose_left >= max_value] = max_value
    respose_right_t[respose_right >= max_value] = max_value

    # Marker sizes
    n_bins = len(bins)
    marker_size_bin = np.zeros(n_bins)
    for bin_i in range(n_bins - 1):
        marker_size_bin[bin_i + 1] = max_marker_size / (2 * (n_bins - 1)) * (1 + bin_i * 2)
    marker_size_bin[-1] = max_marker_size

    # Review left side of all beams
    for story_i in range(n_stories):

        for bay_i in range(n_bays):
            col_i = bay_i

            # Get the index of the correct bin for marker size
            curr_bin = 1
            if respose_left_t[story_i, bay_i] > np.max(bins):
                curr_bin = len(bins)
            else:
                while respose_left_t[story_i, bay_i] > bins[curr_bin]:
                    curr_bin += 1
            # Plot circle
            _ = ax.scatter(joints_x[story_i + 1, col_i] + d_x, joints_y[story_i + 1, col_i],
                           s=marker_size_bin[curr_bin - 1], facecolors=facecolors, color=edgecolor, alpha=0.9)

    # Review right side of all beams
    d_x = -d_x
    for story_i in range(n_stories):

        for bay_i in range(n_bays):
            col_i = bay_i + 1

            # Get the index of the correct bin for marker size
            curr_bin = 1
            if respose_right_t[story_i, bay_i] > np.max(bins):
                curr_bin = len(bins)
            else:
                while respose_right_t[story_i, bay_i] > bins[curr_bin]:
                    curr_bin += 1
            # Plot circle
            _ = ax.scatter(joints_x[story_i + 1, col_i] + d_x, joints_y[story_i + 1, col_i],
                           s=marker_size_bin[curr_bin - 1], facecolors=facecolors, color=edgecolor, alpha=0.9)

    # Plot annotations below the frame to show scale for all non-zero bins
    if addLegend:
        y_gap = -50
        y_between = -150
        for bin_i in range(n_bins - 2):
            _ = ax.scatter(np.mean(joints_x[0]) * 1 / 5, y_gap + y_between * bin_i, s=marker_size_bin[bin_i + 1],
                           facecolors=facecolors,
                           color=edgecolor, alpha=0.9)
            _ = ax.text(np.mean(joints_x[0]) * 1 / 5 + max_marker_size / 4, y_gap * 2 + y_between * bin_i,
                        labelText + ' = ' + str(bins[bin_i + 1]) + ' - ' + str(bins[bin_i + 2]), size=18)

        _ = ax.scatter(np.mean(joints_x[0]) * 1 / 5, y_gap + y_between * (bin_i + 1), s=max_marker_size, facecolors=facecolors,
                       color=edgecolor, alpha=0.9)
        _ = ax.text(np.mean(joints_x[0]) * 1 / 5 + max_marker_size / 4, y_gap * 2 + y_between * (bin_i + 1),
                    labelText + ' $\geq$ ' + str(np.max(bins)), size=18)


def plot_beam_response_bins_edp(ax, t, edp, joints_x, joints_y, respose_left, respose_right, d_x=30, max_value=1,
                                plot_scale=1, max_marker_size=300, labelText='FI', bins=np.array([0, 0.5, 0.75, 0.9]),
                                edgecolor='k', facecolors='none', addLegend=True):
    # Plots response of any continuous quantity of beam end response as a circle of varying size in the correct location
    # in the building. The circle sizes have discrete sizes based on the values in the bin vector
    # The first category has no marker, and the others increase linearly until the maximum size
    #
    # INPUTS
    #     t              = time for deformed shape plot
    #     edp            = 2D np.array [floor_i, time] of the displacement of each floor
    #                    or 3D np.array [floor_i, axis_i, time] of the displacement of each panel zone
    #     joints_x        = np.array of x coordinates of all beam-to-column joints
    #     joints_y        = np.array of y coordinates of all beam-to-column joints
    #     respose_left    = 2D np.array of the response to be plotted on the left side of beams
    #     respose_left    = 2D np.array of the response to be plotted on the right side of beams
    #     d_x             = offset in x for placing the circle
    #     max_value       = maximum value of the quantity to plot
    #     plot_scale  = scale for amplifying displacements
    #     max_marker_size = maximum size of the marker
    #     bins            = np.array of the limits of the beam response to define bins
    #     edgecolor       = color of the edge of the markers
    #     facecolors      = 'none' open circles
    #                     = color of the fill
    #     addLegend       = 'True' add the legend for the bins
    #

    # Retrieve basic info for loops
    n_stories, n_bays = joints_x.shape
    n_stories = n_stories - 1
    n_bays = n_bays - 1

    # Get response at t and replace all values greater than the maximum equal to the maximum
    if respose_left.ndim == 3 and respose_right.ndim == 3:
        ### response history given ###
        respose_left_t = respose_left[:,:,t].copy()
        respose_right_t = respose_right[:,:,t].copy()
        respose_left_t[respose_left_t >= max_value] = max_value
        respose_right_t[respose_right_t >= max_value] = max_value
    elif respose_left.ndim == 2 and respose_right.ndim == 2:
        ### snapshot of the response given ###
        respose_left_t = respose_left.copy()
        respose_right_t = respose_right.copy()
        respose_left_t[respose_left_t >= max_value] = max_value
        respose_right_t[respose_right_t >= max_value] = max_value
    else:
        print('ERROR: non consistent inputs of response to plot')

    # Marker sizes
    n_bins = len(bins)
    marker_size_bin = np.zeros(n_bins)
    for bin_i in range(n_bins - 1):
        marker_size_bin[bin_i + 1] = max_marker_size / (2 * (n_bins - 1)) * (1 + bin_i * 2)
    marker_size_bin[-1] = max_marker_size

    if edp.ndim == 3:
    ### For disp on each column axis ###

        # Add disp to the ground nodes (if not already in edp matrix)
        [n_disps, n_piers, n_pts] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((n_piers, n_pts)), axis=0)

        # Add displacement to each joint index
        joints_x_t = joints_x.copy()
        joints_x_t = joints_x_t + plot_scale * edp[:, :, t]

    elif edp.ndim == 2:
    ### For disp on each column axis ###

        # Add disp to the ground nodes (if not already in edp matrix)
        [n_disps, n_piers] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((1, n_piers)), axis=0)

        # Add displacement to each joint index
        joints_x_t = joints_x.copy()
        joints_x_t = joints_x_t + plot_scale * edp[:, :]

    else:
    ### For one disp input per floor ###

        # Add the ground level displacement
        [n_disps, n_pts] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((1, n_pts)), axis=0)

        # Add displacement to each joint index
        joints_x_t = joints_x.copy()
        for story_i in range(n_stories + 1):  # +1 because starts from the ground
            joints_x_t[story_i, :] = joints_x_t[story_i, :] + plot_scale * edp[story_i, t] * np.ones(
                len(joints_x_t[story_i, :]))

    # Review left side of all beams
    for story_i in range(n_stories):

        for bay_i in range(n_bays):
            col_i = bay_i

            # Get the index of the correct bin for marker size
            curr_bin = 1
            if respose_left_t[story_i, bay_i] > np.max(bins):
                curr_bin = len(bins)
            else:
                while respose_left_t[story_i, bay_i] > bins[curr_bin]:
                    curr_bin += 1
            # Plot circle
            _ = ax.scatter(joints_x_t[story_i + 1, col_i] + d_x, joints_y[story_i + 1, col_i],
                           s=marker_size_bin[curr_bin - 1], facecolors=facecolors, color=edgecolor, alpha=0.9)

    # Review right side of all beams
    d_x = -d_x
    for story_i in range(n_stories):

        for bay_i in range(n_bays):
            col_i = bay_i + 1

            # Get the index of the correct bin for marker size
            curr_bin = 1
            if respose_right_t[story_i, bay_i] > np.max(bins):
                curr_bin = len(bins)
            else:
                while respose_right_t[story_i, bay_i] > bins[curr_bin]:
                    curr_bin += 1
            # Plot circle
            _ = ax.scatter(joints_x_t[story_i + 1, col_i] + d_x, joints_y[story_i + 1, col_i],
                           s=marker_size_bin[curr_bin - 1], facecolors=facecolors, color=edgecolor, alpha=0.9)

    # Plot annotations below the frame to show scale for all non-zero bins
    if addLegend:
        y_gap = -50
        y_between = -150
        for bin_i in range(n_bins - 2):
            _ = ax.scatter(np.mean(joints_x[0]) * 1 / 5, y_gap + y_between * bin_i, s=marker_size_bin[bin_i + 1],
                           facecolors=facecolors,
                           color=edgecolor, alpha=0.9)
            _ = ax.text(np.mean(joints_x[0]) * 1 / 5 + max_marker_size / 4, y_gap * 2 + y_between * bin_i,
                        labelText + ' = ' + str(bins[bin_i + 1]) + ' - ' + str(bins[bin_i + 2]), size=18)

        _ = ax.scatter(np.mean(joints_x[0]) * 1 / 5, y_gap + y_between * (bin_i + 1), s=max_marker_size,
                       facecolors=facecolors,
                       color=edgecolor, alpha=0.9)
        _ = ax.text(np.mean(joints_x[0]) * 1 / 5 + max_marker_size / 4, y_gap * 2 + y_between * (bin_i + 1),
                    labelText + ' $\geq$ ' + str(np.max(bins)), size=18)


def plot_story_response(ax, story_response_to_plot, story_heights, bay_widths,
                        x_ticks=np.array([0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]), color_name='r',
                        xlabel_text='Peak story drift ratio [%]'):


    data = np.vstack((story_response_to_plot, story_response_to_plot[-1]))
    heights = np.array([0])
    heights = np.hstack((heights, story_heights))

    # Scale to ensure parallel to building plot
    building_height = sum(story_heights)
    building_width = sum(bay_widths)
#     y_gap = 500  # same as in building plot function
    x_gap = 100  # same as in building plot function
    scale_for_plot = building_width / np.max(x_ticks)

    _ = ax.step(data * scale_for_plot * 100, np.cumsum(heights), linewidth=2, color=color_name)
#     _ = ax.axis('scaled')

    # Formatting to ensure parallel to building plot
    _ = ax.set_xticks(x_ticks * scale_for_plot)
    _ = ax.set_xticklabels(x_ticks)
    _ = ax.set_xlim(-x_gap, building_width + x_gap)
#     _ = ax.set_ylim(-y_gap/5, building_height + y_gap/5)
    _ = ax.set_yticks(np.cumsum(heights))
    _ = ax.set_yticklabels(np.arange(len(heights)))

    _ = ax.set_ylabel('Floor number')
    _ = ax.set_xlabel(xlabel_text)
    _ = ax.grid(which='both', alpha=0.3)


def plot_column_response(ax, joints_x, joints_y, respose_bot, respose_top, d_y=30, max_value=1, max_marker_size=300):
    # Plots response of any continuous quantity of beam end response as a circle of varying size in the correct location
    # in the building
    #
    # INPUTS
    #     joints_x        = np.array of x coordinates of all beam-to-column joints
    #     joints_y        = np.array of y coordinates of all beam-to-column joints
    #     respose_bot    = 2D np.array of the response to be plotted on the bottom side of beams
    #     respose_top    = 2D np.array of the response to be plotted on the top side of beams
    #     d_y             = offset in y for placing the circle
    #     max_value       = maximum value of the quantity to plot
    #     max_marker_size = maximum size of the marker
    #

    # Retrieve basic info for loops
    n_stories, n_piers = joints_x.shape
    n_stories = n_stories - 1

    # Set all values greater than the maximum equal to the maximum
    respose_bot_t = respose_bot.copy()
    respose_top_t = respose_top.copy()
    respose_bot_t[respose_bot >= max_value] = max_value
    respose_top_t[respose_top >= max_value] = max_value

    # Review bottom side of all beams
    for story_i in range(n_stories):

        for pier_i in range(n_piers):
            marker_size = respose_bot_t[story_i, pier_i] / max_value * max_marker_size
            _ = ax.scatter(joints_x[story_i, pier_i], joints_y[story_i, pier_i] + d_y, s=marker_size,
                           facecolors='none', color='m', alpha=0.9)

    # Review top side of all beams
    d_y = -d_y
    for story_i in range(n_stories):

        for pier_i in range(n_piers):
            marker_size = respose_top_t[story_i, pier_i] / max_value * max_marker_size
            _ = ax.scatter(joints_x[story_i + 1, pier_i], joints_y[story_i + 1, pier_i] + d_y, s=marker_size,
                           facecolors='none', color='m', alpha=0.9)

    # Plot annotation below the frame to show scale
    y_gap = -50
    _ = ax.scatter(np.mean(joints_x[0]), y_gap, s=max_marker_size, facecolors='none', color='m', alpha=0.9)
    _ = ax.text(np.mean(joints_x[0]) + max_marker_size / 4, y_gap * 2, 'Size = ' + str(max_value), size=18)


def plot_column_response_bins_edp(ax, t, edp, joints_x, joints_y, respose_bot, respose_top, d_y=30, max_value=1,
                                  plot_scale=1, max_marker_size=300, labelText='\\theta_p',
                                  bins=np.array([0, 0.5, 0.75, 0.9]),
                                  edgecolor='k', facecolors='none', addLegend=True):
    # Plots response of any continuous quantity of beam end response as a circle of varying size in the correct location
    # in the building. The circle sizes have discrete sizes based on the values in the bin vector
    # The first category has no marker, and the others increase linearly until the maximum size
    #
    # INPUTS
    #     t               = time for deformed shape plot
    #     edp             = 2D np.array [floor_i, time] of the displacement of each floor
    #                    or 3D np.array [floor_i, axis_i, time] of the displacement of each panel zone
    #     joints_x        = np.array of x coordinates of all beam-to-column joints
    #     joints_y        = np.array of y coordinates of all beam-to-column joints
    #     respose_bot     = 2D np.array of the response to be plotted on the bottom side of beams
    #     respose_top     = 2D np.array of the response to be plotted on the top side of beams
    #     d_y             = offset in y for placing the circle
    #     max_value       = maximum value of the quantity to plot
    #     plot_scale  = scale for amplifying displacements
    #     max_marker_size = maximum size of the marker
    #     bins            = np.array of the limits of the beam response to define bins
    #     edgecolor       = color of the edge of the markers
    #     facecolors      = 'none' open circles
    #                     = color of the fill
    #     addLegend       = 'True' add the legend for the bins
    #

    # Retrieve basic info for loops
    n_stories, n_piers = joints_x.shape
    n_stories = n_stories - 1

    # Set all values greater than the maximum equal to the maximum
    if respose_bot.ndim == 3 and respose_top.ndim == 3:
        respose_bot_t = respose_bot[:,:,t].copy()
        respose_top_t = respose_top[:,:,t].copy()
    elif respose_bot.ndim == 2 and respose_top.ndim == 2:
        respose_bot_t = respose_bot.copy()
        respose_top_t = respose_top.copy()
    respose_bot_t[respose_bot_t >= max_value] = max_value
    respose_top_t[respose_top_t >= max_value] = max_value

    # Marker sizes
    n_bins = len(bins)
    marker_size_bin = np.zeros(n_bins)
    for bin_i in range(n_bins - 1):
        marker_size_bin[bin_i + 1] = max_marker_size / (2 * (n_bins - 1)) * (1 + bin_i * 2)
    marker_size_bin[-1] = max_marker_size

    if edp.ndim == 3:
        ### For disp on each column axis ###
        # Add disp to the ground nodes (if not already in edp matrix)
        [n_disps, n_piers, n_pts] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((n_piers, n_pts)), axis=0)

        # Add displacement to each joint index
        joints_x_t = joints_x.copy()
        joints_x_t = joints_x_t + plot_scale * edp[:, :, t]

    elif edp.ndim == 2:
        ### For disp on each column axis ###
        # Add disp to the ground nodes (if not already in edp matrix)
        [n_disps, n_piers] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((1, n_piers)), axis=0)

        # Add displacement to each joint index
        joints_x_t = joints_x.copy()
        joints_x_t = joints_x_t + plot_scale * edp[:, :]

    else:
        ### For one disp input per floor ###

        # Add the ground level displacement
        [n_disps, n_pts] = edp.shape
        if n_disps < n_stories + 1:
            edp = np.insert(edp, 0, np.zeros((1, n_pts)), axis=0)

        # Add displacement to each joint index
        joints_x_t = joints_x.copy()
        for story_i in range(n_stories + 1):  # +1 because starts from the ground
            joints_x_t[story_i, :] = joints_x_t[story_i, :] + plot_scale * edp[story_i, t] * np.ones(
                len(joints_x_t[story_i, :]))

    # Review bottom side of all beams
    for story_i in range(n_stories):

        for pier_i in range(n_piers):
            # Get the index of the correct bin for marker size
            curr_bin = 1
            if respose_bot_t[story_i, pier_i] > np.max(bins):
                curr_bin = len(bins)
            else:
                while respose_bot_t[story_i, pier_i] > bins[curr_bin]:
                    curr_bin += 1
            # Plot circle
            _ = ax.scatter(joints_x_t[story_i, pier_i], joints_y[story_i, pier_i] + d_y,
                           s=marker_size_bin[curr_bin - 1], facecolors=facecolors, color=edgecolor, alpha=0.9)

    # Review top side of all beams
    d_y = -d_y
    for story_i in range(n_stories):

        for pier_i in range(n_piers):
            # Get the index of the correct bin for marker size
            curr_bin = 1
            if respose_top_t[story_i, pier_i] > np.max(bins):
                curr_bin = len(bins)
            else:
                while respose_top_t[story_i, pier_i] > bins[curr_bin]:
                    curr_bin += 1
            # Plot circle
            _ = ax.scatter(joints_x_t[story_i + 1, pier_i], joints_y[story_i + 1, pier_i] + d_y,
                           s=marker_size_bin[curr_bin - 1], facecolors=facecolors, color=edgecolor, alpha=0.9)

    # Plot annotations below the frame to show scale for all non-zero bins
    if addLegend:
        y_gap = -50
        y_between = -150
        for bin_i in range(n_bins - 2):
            _ = ax.scatter(np.mean(joints_x[0]) * 1 / 5, y_gap + y_between * bin_i,
                           s=marker_size_bin[bin_i + 1],
                           facecolors=facecolors,
                           color=edgecolor, alpha=0.9)
            _ = ax.text(np.mean(joints_x[0]) * 1 / 5 + max_marker_size / 4, y_gap * 2 + y_between * bin_i,
                        labelText + ' = ' + str(bins[bin_i + 1]) + ' - ' + str(bins[bin_i + 2]), size=18)

        _ = ax.scatter(np.mean(joints_x[0]) * 1 / 5, y_gap + y_between * (bin_i + 1), s=max_marker_size,
                       facecolors=facecolors,
                       color=edgecolor, alpha=0.9)
        _ = ax.text(np.mean(joints_x[0]) * 1 / 5 + max_marker_size / 4, y_gap * 2 + y_between * (bin_i + 1),
                    labelText + ' $\geq$ ' + str(np.max(bins)), size=18)


def panel_zone_model2021(dc, bcf, tcf, tcw, tdp, db, Fy=45, Es=2900):
    # Computes the modeling parameters of a panel zone given its geometry per:
    #   Skiadopoulos, Elkadi and Lignos (2021) Proposed Panel Zone Model for Seismic Design of Steel Moment-Resisting Frames
    #   Journal of Structural Engineering ASCE, 147(4)
    #
    # INPUTS
    #    dc  = column depth
    #    bcf = column flange width
    #    tcf = column flange thichness
    #    tcw = column web thickness
    #    tdp = doubler plate thickness
    #    db  = beam depth
    #    Fy  = column steel yielding stress
    #    Es  = column steel elastic modulus
    #
    # OUTPUTS
    #    gamma_y = panel zone shear strain at first yield
    #

    # Steel shear modulus
    Gs = Es / (2 * (1 + 0.2))

    # Panel zone elastic stiffness
    tpz = tcw + tdp  # total panel zone thickness
    # Ic = Ic + 1/12*tdb*(dc - 2*tcf - 0.5)^3 # second moment of area of the column including doubler plate
    Ic = 1 / 12 * tcw * (dc - tcf) ** 3 + 2 * (
                1 / 12 * bcf * tcf ** 3 + (tcf * bcf) * (dc / 2 - tcf / 2) ** 2) + 1 / 12 * tdp * (
                     dc - 2 * tcf - 0.5) ** 3  # second moment of area of the column including doubler plate
    Ks = tpz * (dc - tcf) * Gs  # shear stiffness
    Kb = (12 * Es * Ic / db ** 3) * db  # bening stiffness
    Ke = Ks * Kb / (Ks + Kb)  # Equivalent stiffness

    # Column flanges stiffness
    Ksf = 2 * (tcf * bcf * Gs)
    Kbf = 2 * (12 * Es * (bcf * tcf ** 3 / 12) / db ** 3) * db
    Kf = Ksf * Kbf / (Ksf + Kbf)

    # Panel zone yielding strength
    Vy = ((0.58 * Kf / Ke + 0.88) / (1 - Kf / Ke)) * (Fy / np.sqrt(3)) * (dc - tcf) * tpz

    # Panel zone yielding strain
    gamma_y = Vy / Ke

    return gamma_y, Ke


def web_fibers_model(bolt_location):
    # Computes the displacement capacity of web-tab-bolt fibers on bolted connections per:
    #   Main and Sadek (2012) Robustness of Steel Gravity Frame Systems with Single-Plate Shear Connections
    #   (NIST Technical Note 1749)
    #
    # INPUTS
    #    bolt_location = list of bolt locations measured from the center of the beam MEASURED IN INCHES!!!!
    #
    # OUTPUTS
    #    delta_u = fiber displacement to peak axial force
    #    delta_f = fiber displacement to bolt shear failure
    #

    d_bg = min(bolt_location) + max(bolt_location)  # vertical distance from first to last bolt

    # Displacement to bolt or tab fracture (USE INCHES)
    delta_u = 0.085 * d_bg - 0.0018 * d_bg ** 2

    # Displacement to bolt shear failure
    delta_f = delta_u * 1.15

    return delta_u, delta_f


def di_fema352_deterministic(beam_list, column_list, frac_simulated, webfiber_strain, webfiber_defu, webfiber_deff,
                             beam_plas_rot, beam_thetaCap, column_response, col_thetaCap_hinge_bot, col_thetaCap_hinge_top,
                             col_thetaUlt_hinge_bot, col_thetaUlt_hinge_top, pz_response, pz_gammay):
    # di_fema352 takes all the information of the response and capacity of every beam-to-column connection (fracture,
    # beam rotation, column rotation, and panel zone rotation) and computes the FEMA 352 damage index per connection
    # and floor.
    #
    # INPUTS
    #   beam_list              = np.array of No.Floors x No.bays with 1 in the bays that do have a beam
    #   column_list            = np.array of No.stories x No.bays with 1 in the story that do have a column
    #   frac_simulated         = dictionary with np.arrays (No.Floors x No.bays) that have a boolean for each beam-to-column
    #                            connection if fracture occurred.
    #                            'frac_LB': left bottom flange
    #                            'frac_LT': left top flange
    #                            'frac_RB': right bottom flange
    #                            'frac_RT': right top flange
    #   webfiber_strain        = dictionary with np.arrays (No.Floors x No.bays) that have the displacement for web fibers in
    #                            each beam-to-column connection.
    #                            'webfiber_L1': left bottom fiber
    #                            'webfiber_L2': left 2nd to bottom fiber
    #                            'webfiber_L3': left 3rd to bottom fiber
    #                            'webfiber_R1': right bottom fiber
    #                            'webfiber_R2': right 2nd to bottom fiber
    #                            'webfiber_R3': right 3rd to bottom fiber
    #   webfiber_defu          = np.arrays (No.Floors x No.bays) with the displacement at maximum load for web fibers
    #   webfiber_deff          = np.arrays (No.Floors x No.bays) with the displacement capacity for web fibers
    #   beam_plas_rot          = dictionary with np.arrays (No.Floors x No.bays) with the rotation demand for beam hinges
    #                            'hinge_left' : left hinge
    #                            'hinge_right': right hinge
    #   beam_thetaCap          = np.arrays (No.Floors x No.bays) with the rotation at maximum load for beam hinges
    #   column_response        = dictionary with np.arrays (No.Floors x No.piers) with the rotation demand for column hinges
    #                            'hinge_top'   : top hinge
    #                            'hinge_bottom': bottom hinge
    #   col_thetaCap_hinge_bot = np.arrays (No.Floors x No.piers) with the rotation at maximum load for bottom column hinges
    #   col_thetaCap_hinge_top = np.arrays (No.Floors x No.piers) with the rotation at maximum load for top column hinges
    #   col_thetaUlt_hinge_bot = np.arrays (No.Floors x No.piers) with the rotation capacity for bottom column hinges
    #   col_thetaUlt_hinge_top = np.arrays (No.Floors x No.piers) with the rotation capacity for top column hinges
    #   pz_response            = dictionary with np.arrays (No.Floors x No.piers) with the rotation demand for panel zones
    #                            'pz_rot'   : panel zone rotation
    #   pz_gammay              = np.arrays (No.Floors x No.piers) with the yielding rotation for panel zones
    #
    # OUTPUT
    #   FDI   = np.array with the FEMA352 damage index per floor of the building

    n_floors, n_bays = beam_list.shape

    ############## G3, G4, C2, W2, W3 and W4 damages ##############
    d_type1 = np.zeros([n_floors, n_bays * 2])  # columns are bay 1 left- bay 1 right - bay 2 left - bay 2 right
    d_type1[:, 0:n_bays * 2:2] = (frac_simulated['frac_LB'] + frac_simulated['frac_LT']) * 2
    d_type1[:, 1:n_bays * 2:2] = (frac_simulated['frac_RB'] + frac_simulated['frac_RT']) * 2

    #     d_type1

    ###################### S1 to S6 damages #######################
    d_type2 = np.zeros([n_floors, n_bays * 2])  # columns are bay 1 left- bay 1 right - bay 2 left - bay 2 right

    for i in range(n_floors):
        for j in range(n_bays):
            #### Left side ####
            fiber1 = webfiber_strain['webfiber_L1'][i, j]  # further in tension
            fiber2 = webfiber_strain['webfiber_L2'][i, j]
            fiber3 = webfiber_strain['webfiber_L3'][i, j]

            fiber_du = webfiber_defu[i, j]
            fiber_df = webfiber_deff[i, j]

            # Map displacement of web fibers to a di
            if fiber1 > fiber_du / 2 and fiber1 < fiber_du:
                di = 1
            elif fiber1 > fiber_du and fiber2 < fiber_du:
                di = 2
            elif fiber1 > fiber_du and fiber2 > fiber_du and fiber3 < fiber_du:
                di = 3
            elif fiber1 > fiber_df or (fiber1 > fiber_du and fiber2 > fiber_du and fiber3 > fiber_du):
                di = 4
            else:
                di = 0

            # Add to matrix
            d_type2[i, 2 * j] = di

            #### Right side ####
            fiber1 = webfiber_strain['webfiber_R1'][i, j]  # further in tension
            fiber2 = webfiber_strain['webfiber_R2'][i, j]
            fiber3 = webfiber_strain['webfiber_R3'][i, j]

            fiber_du = webfiber_defu[i, j]
            fiber_df = webfiber_deff[i, j]

            # Map displacement of web fibers to a di
            if fiber1 > fiber_du / 2 and fiber1 < fiber_du:
                di = 1
            elif fiber1 > fiber_du and fiber2 < fiber_du:
                di = 2
            elif fiber1 > fiber_du and fiber2 > fiber_du and fiber3 < fiber_du:
                di = 3
            elif fiber1 > fiber_df or (fiber1 > fiber_du and fiber2 > fiber_du and fiber3 > fiber_du):
                di = 4
            else:
                di = 0

            # Add to matrix
            d_type2[i, 2 * j + 1] = di

        #     d_type2

    ###################### G1 and G8 damages ######################
    d_type3 = np.zeros([n_floors, n_bays * 2])  # columns are bay 1 left- bay 1 right - bay 2 left - bay 2 right

    temp_left = np.divide(beam_plas_rot['hinge_left'], beam_thetaCap)
    temp_left[np.isnan(temp_left)] = 0
    temp_left[temp_left > 1] = 2
    temp_left[temp_left < 1] = 0

    temp_right = np.divide(beam_plas_rot['hinge_right'], beam_thetaCap)
    temp_right[np.isnan(temp_right)] = 0
    temp_right[temp_left > 1] = 2
    temp_right[temp_left < 1] = 0

    d_type3[:, 0:n_bays * 2:2] = temp_left
    d_type3[:, 1:n_bays * 2:2] = temp_right

        #     d_type3

    ###################### C1, C5 and C6 damages ######################
    d_type4 = np.zeros([n_floors, n_bays * 2])  # columns are bay 1 left- bay 1 right - bay 2 left - bay 2 right

    #### damage of the bottom hinge of the column above
    temp_bot = np.divide(column_response['hinge_bot'], col_thetaCap_hinge_bot)
    temp_bot[np.isnan(temp_bot)] = 0
    temp_bot[temp_bot < 0.5] = 0
    temp_bot[np.logical_and(temp_bot > 0.5, temp_bot < 1)] = 1
    temp_bot[temp_bot > 1] = 2

    temp_bot_2 = np.divide(column_response['hinge_bot'], col_thetaUlt_hinge_bot)
    temp_bot_2[np.isnan(temp_bot_2)] = 0
    temp_bot_2[temp_bot_2 > 1] = 3
    temp_bot_2[temp_bot_2 < 1] = 0

    temp_bot = temp_bot + temp_bot_2
    temp_bot[temp_bot >= 3] = 3

    n_pier = n_bays + 1
    for i_story in np.arange(1, n_floors):  # starts from 1 not 0
        i_floor = i_story - 1
        for i_pier in range(n_pier):
            if column_list[i_story, i_pier] > 0:  # jump if setbacks
                if beam_list[i_floor, min(i_pier, n_pier - 2)]:  # continue if one beam at one side
                    # exterior column
                    if i_pier == 0 or beam_list[i_floor, min(max(0, i_pier - 1),
                                                             n_pier - 2)] == 0:  # np.logical_and(i_pier >= 1, column_list[i_story, i_pier-1] == 0):
                        d_type4[i_floor, 2 * i_pier] = temp_bot[i_story, i_pier]
                    elif i_pier == n_pier - 1:
                        d_type4[i_floor, -1] = temp_bot[i_story, i_pier]
                    else:
                        # Interior columns
                        d_type4[i_floor, 2 * i_pier] = temp_bot[i_story, i_pier]
                        d_type4[i_floor, 2 * i_pier - 1] = temp_bot[i_story, i_pier]

    #### damage of the top hinge of the column below
    temp_top = np.divide(column_response['hinge_top'], col_thetaCap_hinge_top)
    temp_top[np.isnan(temp_top)] = 0
    temp_top[temp_top < 0.5] = 0
    temp_top[np.logical_and(temp_top > 0.5, temp_top < 1)] = 1
    temp_top[temp_top > 1] = 2

    temp_top_2 = np.divide(column_response['hinge_top'], col_thetaUlt_hinge_top)
    temp_top_2[np.isnan(temp_top_2)] = 0
    temp_top_2[temp_top_2 > 1] = 3
    temp_top_2[temp_top_2 < 1] = 0

    temp_top = temp_top + temp_top_2
    temp_top[temp_top >= 3] = 3

    n_pier = n_bays + 1
    for i_story in range(n_floors):  # does not involves
        i_floor = i_story
        for i_pier in range(n_pier):
            if column_list[i_story, i_pier] > 0:  # jump if setbacks
                if beam_list[i_floor, min(i_pier, n_pier - 2)]:  # continue if one beam at one side
                    # exterior column
                    if i_pier == 0 or beam_list[i_floor, min(max(0, i_pier - 1),
                                                             n_pier - 2)] == 0:  # np.logical_and(i_pier >= 1, column_list[i_story, i_pier-1] == 0):
                        d_type4[i_floor, 2 * i_pier] = temp_top[i_story, i_pier]
                    elif i_pier == n_pier - 1:
                        d_type4[i_floor, -1] = temp_top[i_story, i_pier]
                    else:
                        # Interior columns
                        d_type4[i_floor, 2 * i_pier] = temp_top[i_story, i_pier]
                        d_type4[i_floor, 2 * i_pier - 1] = temp_top[i_story, i_pier]

            # d_type4

    ###################### P6 to P8 damages ######################
    d_type5 = np.zeros([n_floors, n_bays * 2])  # columns are bay 1 left- bay 1 right - bay 2 left - bay 2 right

    temp_pz = np.divide(pz_response['pz_rot'], pz_gammay)
    temp_pz[np.isnan(temp_pz)] = 0
    temp_pz[temp_pz < 6] = 0
    temp_pz[np.logical_and(temp_pz > 6, temp_pz < 8)] = 2
    temp_pz[np.logical_and(temp_pz > 8, temp_pz < 10)] = 3
    temp_pz[temp_pz > 10] = 4

    n_pier = n_bays + 1
    for i_story in range(n_floors):  # does not involves
        i_floor = i_story
        for i_pier in range(n_pier):
            if column_list[i_story, i_pier] > 0:  # jump if setbacks
                if beam_list[i_floor, min(i_pier, n_pier - 2)]:  # continue if one beam at one side
                    # exterior column
                    if i_pier == 0 or beam_list[i_floor, min(max(0, i_pier - 1),
                                                             n_pier - 2)] == 0:  # np.logical_and(i_pier >= 1, column_list[i_story, i_pier-1] == 0):
                        d_type5[i_floor, 2 * i_pier] = temp_pz[i_story, i_pier]
                    elif i_pier == n_pier - 1:
                        d_type5[i_floor, -1] = temp_pz[i_story, i_pier]
                    else:
                        # Interior columns
                        d_type5[i_floor, 2 * i_pier] = temp_pz[i_story, i_pier]
                        d_type5[i_floor, 2 * i_pier - 1] = temp_pz[i_story, i_pier]

    #     d_type5

    # Number of connections per floor
    n = np.sum(2 * beam_list, axis=1)

    # FEMA 352 Damage Index
    di = d_type1 + d_type2 + d_type3 + d_type4 + d_type5
    di[di > 4] = 4
    di = np.sum(di, axis=1)
    FDI = np.divide(di / 4, n)

    return FDI


def compute_msa_fragility(p_stripes, stripe_values, plot):
    # compute_msa_fragility takes the fraction of collapse cases for a list of stripes and
    # fits a lognormal probability function
    #
    # INPUTS
    #   p_stripes       = list with the fraction of collapses per stri[e
    #   stripe_values   = list of IM value per stripe
    #   plot            = true/false to plot fragility
    #
    # OUTPUTS
    #   median  = median IM of collapse
    #   beta    = log standard deviation of collapse fragility
    #

    # set the initial median
    p_target = 0.5
    # linear interpolation for the im resulting in p_target collapses
    if np.any(p_stripes >= p_target):
        median_0 = np.interp(p_target, p_stripes, stripe_values)
    # or take the max im value
    else:
        median_0 = stripe_values[-1]

    # standard deviation starts with 0.2
    sigma0 = 0.2

    # convergence flag for optimization
    conv_flag = 0
    while not conv_flag and sigma0 < 1.0:
        # Fit fragility using maximimun likelihood
        x0 = [median_0, sigma0]
        res = optimize.minimize(msa_log_likelihood, x0, args=(stripe_values, p_stripes),
                                method='Nelder-Mead', options={'maxiter': 100})
        conv_flag = res.success
        median, beta = res.x
        sigma0 = sigma0 + 0.05

    if plot:
        y = np.linspace(0.001, 1, num=100)
        x = stats.lognorm(beta, scale=median).ppf(y)
        _ = plt.plot(x, y)
        _ = plt.scatter(stripe_values, p_stripes)

    return median, beta


def msa_log_likelihood(parameters, stripe_values, p_stripes):
    # msa_log_likelihood computes the maximum likelihood for a lognormal distribution

    [median, beta] = parameters

    # big sampling number
    bignum = 1000

    num_yy = np.around(bignum * p_stripes).reshape((-1, 1))
    n_stripes = len(stripe_values)

    p_stripes = [stats.lognorm(beta, scale=median).cdf(im) for im in stripe_values]
    stripe_likelihoods = np.array([stats.binom(bignum, p_stripes[i]).pmf(num_yy[i]) for i in range(n_stripes)])

    log_likelihood = - np.sum(np.log(stripe_likelihoods))

    return log_likelihood


def plot_response_in_height(EDP, edp2plot, title_text, edp_limits, ax, add_stats=True, color_record='lightgrey',
                            color_stats='tab:blue'):
    # plot_response_in_height plots the story edp's for a building along the height
    #
    # INPUTS
    #   EDP        = name of the EDP to plot, used to get x-label (often 'PID' or 'RID' or 'PFA')
    #   edp2plot   = list of np.arrays (one per record) or 2D-np.array (n_record x n_stories) with the EDP values to plot
    #   title_text = string for plot text
    #   edp_limits = [min x, max x] to plot
    #   ax         = axis for the plot
    #

    # format input
    edp2plot = np.array(edp2plot).astype(float)
    n_records, n_stories = edp2plot.shape
    story_list = np.linspace(0, n_stories-1, n_stories)

    # Add ground values (repeat those from first story)
    #     edp2plot = np.concatenate((edp2plot[:,0].reshape(1,-1), edp2plot.T)).T

    # Compute median and std deviation
    median = np.mean(np.log(edp2plot), 0)
    std_dev = np.std(np.log(edp2plot), 0)

    # Get x-label
    if EDP == 'PID':
        edp_label = '$PID_{max}$ []'
    elif EDP == 'RID':
        edp_label = '$RID_{max}$ []'
    elif EDP == 'PFA':
        edp_label = '$PFA_{max}$ [g]'
    else:
        edp_label = ''

    for i in range(len(edp2plot)):
        _ = ax.step(edp2plot[i], story_list, color=color_record, alpha=0.5, linewidth=1)

    if add_stats:
        _ = ax.step(np.exp(median), story_list, color=color_stats, alpha=1, linewidth=2)
        _ = ax.step(np.exp(median + std_dev), story_list, color=color_stats, alpha=1, linestyle='dashed', linewidth=1.5)
        _ = ax.step(np.exp(median - std_dev), story_list, color=color_stats, alpha=1, linestyle='dashed', linewidth=1.5)

    if edp_limits != 999:
        _ = ax.set_xlim(edp_limits)

    _ = ax.grid(which='both', alpha=0.3)
    _ = ax.set_ylim([0.5, n_stories+0.5])
    _ = ax.set_xlabel(edp_label)
    _ = ax.set_ylabel('Story #')
    _ = ax.set_title(title_text, loc='right')
    # _ = plt.legend(loc='best', bbox_to_anchor=(1, 0, 0.45, 0.5))
    # _ = plt.tight_layout()

def risk_convolution_old(im_exceedance_frequency, im_list, fragilities):
    # plot_response_in_height plots the story edp's for a building along the height
    #
    # INPUTS
    #   im_exceedance_frequency = mean annual freq. of exceedence of each IM in im_list for the hazard curve
    #   im_list                 = 1D array or list with the IM values for the hazard curve
    #   fragilities             = dictionary with 'Median' and 'Beta' lists for the buildings to
    #                             compute collapse risk
    #

    medians = fragilities['Median']
    betas = fragilities['Beta']

    freq = im_exceedance_frequency
    dim = im_list[1] - im_list[0]

    dfreq_im = [np.abs((freq[i + 1] - freq[i]) / dim) for i in range(len(im_list) - 1)]
    dfreq_im = np.append(dfreq_im, dfreq_im[-1])

    if type(medians) is not list:
        medians = [medians]
        betas = [betas]

    freq_collapse = np.zeros(len(medians))
    for median, beta, i in zip(medians, betas, range(len(medians))):
        p_collapse_im = stats.lognorm(beta, scale=median).cdf(im_list)
        y = p_collapse_im * dfreq_im
        freq_collapse[i] = np.trapz(y, dx=dim)

    return freq_collapse


def risk_convolution_poly(im_exceedance_frequency, im_list, fragilities, deg=4):
    # plot_response_in_height plots the story edp's for a building along the height
    #
    # INPUTS
    #   im_exceedance_frequency = mean annual freq. of exceedence of each IM in im_list for the hazard curve
    #   im_list                 = 1D array or list with the IM values for the hazard curve
    #   fragilities             = dictionary with 'Median' and 'Beta' lists for the buildings to
    #                             compute collapse risk
    #   deg                     = degree of the polynomial function to fit the hazard curve
    #

    medians = fragilities['Median']
    betas = fragilities['Beta']

    # Linear interpolation of the hazard curve in log space
    #     im   = np.linspace(min(im_list), max(im_list), 500)
    #     freq = np.exp(np.interp(np.log(im), np.log(im_list), np.log(im_exceedance_frequency)))
    #     dim  = im[1] - im[0]
    #     slope = np.abs(np.diff(freq)/dim)
    #     slope = np.hstack([slope, slope[-1]])

    # Polyfit interpolation of the hazard curve
    im = np.linspace(min(im_list), max(im_list), 500)
    freq = np.exp(np.interp(np.log(im), np.log(im_list), np.log(im_exceedance_frequency)))
    dim = im[1] - im[0]
    deg = 3  # degree of the polinomial fit
    p = np.polyfit(np.log(im), np.log(freq), deg)
    slope = []
    for i in range(len(im)):
        if deg == 3:
            slope.append(((p[2] + 2 * p[1] * np.log(im[i]) + 3 * p[0] * np.log(im[i]) ** 2) / im[i]) * np.exp(
                p[3] + p[2] * np.log(im[i]) + p[1] * np.log(im[i]) ** 2 + p[0] * np.log(im[i]) ** 3))
        elif deg == 4:
            slope.append(((p[3] + 2 * p[2] * np.log(im[i]) + 3 * p[1] * np.log(im[i]) ** 2 + 4 * p[0] * np.log(
                im[i]) ** 3) / im[i]) * np.exp(
                p[4] + p[3] * np.log(im[i]) + p[2] * np.log(im[i]) ** 2 + p[1] * np.log(im[i]) ** 3 + p[0] * np.log(
                    im[i]) ** 4))
        else:
            print('deg must be 3 or 4')
    slope = np.abs(slope)

    # Identify fragility format
    if type(medians) is not list:
        medians = [medians]
        betas = [betas]

    # Integrate over the hazard curve
    freq_collapse = np.zeros(len(medians))
    for median, beta, i in zip(medians, betas, range(len(medians))):
        p_collapse_im = stats.lognorm(beta, scale=median).cdf(im)
        deagg = p_collapse_im * slope
        freq_collapse[i] = np.trapz(deagg, x=im)

    return freq_collapse


def EAL_poly(im_exceedance_frequency, im_list, im_loss, loss_given_im, rp_no_loss=25, deg=4):
    # plot_response_in_height plots the story edp's for a building along the height
    #
    # INPUTS
    #   im_exceedance_frequency = mean annual freq. of exceedence of each IM in im_list for the hazard curve
    #   im_list                 = 1D array or list with the IM values for the hazard curve
    #   im_loss                 = 1D array or list with the IM values corresponding to the loss estimates
    #   loss_given_im           = 1D array or list with the loss estimates
    #   rp_no_loss              = return period for no loss
    #   deg                     = degree of the polynomial function to fit the hazard curve
    #

    # Linear interpolation of the hazard curve in log space
    #     im   = np.linspace(min(im_list), max(im_list), 500)
    #     freq = np.exp(np.interp(np.log(im), np.log(im_list), np.log(im_exceedance_frequency)))
    #     dim  = im[1] - im[0]
    #     slope = np.abs(np.diff(freq)/dim)
    #     slope = np.hstack([slope, slope[-1]])

    # Polyfit interpolation of the hazard curve
    im = np.linspace(min(im_list), max(im_list), 500)
    freq = np.exp(np.interp(np.log(im), np.log(im_list), np.log(im_exceedance_frequency)))
    dim = im[1] - im[0]
    deg = 3  # degree of the polinomial fit
    p = np.polyfit(np.log(im), np.log(freq), deg)
    slope = []
    for i in range(len(im)):
        if deg == 3:
            slope.append(((p[2] + 2 * p[1] * np.log(im[i]) + 3 * p[0] * np.log(im[i]) ** 2) / im[i]) * np.exp(
                p[3] + p[2] * np.log(im[i]) + p[1] * np.log(im[i]) ** 2 + p[0] * np.log(im[i]) ** 3))
        elif deg == 4:
            slope.append(((p[3] + 2 * p[2] * np.log(im[i]) + 3 * p[1] * np.log(im[i]) ** 2 + 4 * p[0] * np.log(
                im[i]) ** 3) / im[i]) * np.exp(
                p[4] + p[3] * np.log(im[i]) + p[2] * np.log(im[i]) ** 2 + p[1] * np.log(im[i]) ** 3 + p[0] * np.log(
                    im[i]) ** 4))
        else:
            print('deg must be 3 or 4')
    slope = np.abs(slope)

    # IM no loss
    im_no_loss = np.exp(np.interp(np.log(1/rp_no_loss), np.log(im_exceedance_frequency), np.log(im_list)))
    if np.min(im_loss) >= im_no_loss:
        im_loss = np.hstack([0, im_no_loss, im_loss])
        loss_given_im = np.hstack([0, 0, loss_given_im])
    else:
        im_loss = np.hstack([0, im_loss])
        loss_given_im = np.hstack([0, loss_given_im])
        for i in range(len(im_loss)):
            if im_loss[i] < im_no_loss:
                loss_given_im[i] = 0

    # Integrate over the hazard curve
    loss = np.interp(im, im_loss, loss_given_im)
    deagg = loss * slope
    EAL = np.trapz(deagg, dx=dim)

    return EAL, deagg, im


def EAL_poly(im_exceedance_frequency, im_list, im_loss, loss_given_im, rp_no_loss=25, deg=4):
    # plot_response_in_height plots the story edp's for a building along the height
    #
    # INPUTS
    #   im_exceedance_frequency = mean annual freq. of exceedence of each IM in im_list for the hazard curve
    #   im_list                 = 1D array or list with the IM values for the hazard curve
    #   im_loss                 = 1D array or list with the IM values corresponding to the loss estimates
    #   loss_given_im           = 1D array or list with the loss estimates
    #   rp_no_loss              = return period for no loss
    #   deg                     = degree of the polynomial function to fit the hazard curve
    #

    # Linear interpolation of the hazard curve in log space
    #     im   = np.linspace(min(im_list), max(im_list), 500)
    #     freq = np.exp(np.interp(np.log(im), np.log(im_list), np.log(im_exceedance_frequency)))
    #     dim  = im[1] - im[0]
    #     slope = np.abs(np.diff(freq)/dim)
    #     slope = np.hstack([slope, slope[-1]])

    # Polyfit interpolation of the hazard curve
    im = np.linspace(min(im_list), max(im_list), 500)
    freq = np.exp(np.interp(np.log(im), np.log(im_list), np.log(im_exceedance_frequency)))
    dim = im[1] - im[0]
    deg = 3  # degree of the polinomial fit
    p = np.polyfit(np.log(im), np.log(freq), deg)
    slope = []
    for i in range(len(im)):
        if deg == 3:
            slope.append(((p[2] + 2 * p[1] * np.log(im[i]) + 3 * p[0] * np.log(im[i]) ** 2) / im[i]) * np.exp(
                p[3] + p[2] * np.log(im[i]) + p[1] * np.log(im[i]) ** 2 + p[0] * np.log(im[i]) ** 3))
        elif deg == 4:
            slope.append(((p[3] + 2 * p[2] * np.log(im[i]) + 3 * p[1] * np.log(im[i]) ** 2 + 4 * p[0] * np.log(
                im[i]) ** 3) / im[i]) * np.exp(
                p[4] + p[3] * np.log(im[i]) + p[2] * np.log(im[i]) ** 2 + p[1] * np.log(im[i]) ** 3 + p[0] * np.log(
                    im[i]) ** 4))
        else:
            print('deg must be 3 or 4')
    slope = np.abs(slope)

    # IM no loss
    im_no_loss = np.interp(1 / rp_no_loss, np.flip(im_exceedance_frequency), np.flip(im_list))
    if np.min(im_loss) >= im_no_loss:
        im_loss = np.hstack([0, im_no_loss, im_loss])
        loss_given_im = np.hstack([0, 0, loss_given_im])
    else:
        im_loss = np.hstack([0, im_loss])
        loss_given_im = np.hstack([0, loss_given_im])
        for i in range(len(im_loss)):
            if im_loss[i] <= im_no_loss:
                loss_given_im[i] = 0

    # Integrate over the hazard curve
    loss = np.interp(im, im_loss, loss_given_im)
    deagg = loss * slope
    EAL = np.trapz(deagg, dx=dim)

    return EAL, deagg, im

