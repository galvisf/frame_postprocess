from .base import *


def plot_building_at_t(t, edp, columns, beams, plot_scale, column_list, beam_list, ax):
    # Take LineCollections objects of the columns and beams and plots them including the displacements at
    # a given time t
    #
    # INPUTS
    #    t           = time for deformed shape plot
    #    edp         = 2D np.array [floor_i, time] of the displacement of each floor
    #    columns     = LineCollection of columns
    #    beams       = LineCollections of beams
    #    plot_scale  = scale for amplifying displacements
    #    column_list = 2D np.array [stories, pier lines]
    #    beam_list   = 2D np.array [floors, bays]
    #    ax          = axes to plot in

    ax.cla()

    [_, n_pts] = edp.shape
    edp = np.insert(edp, 0, np.zeros((1, n_pts)), axis=0)

    [n_columns, _, _] = columns.shape
    [n_beams, _, _] = beams.shape
    n_stories = int(n_columns - n_beams)
    n_bays = int(n_beams / n_stories)

    columns_t = columns.copy()
    beams_t = beams.copy()

    # Get number of columns per story and beams per floor
    columns_story = np.sum(column_list, axis=1)
    beams_floor = np.sum(beam_list, axis=1)

    # Add the displacement of the floor to each column and beam
    i_col = 0
    i_beam = 0
    for i_story in range(n_stories):
        for i_end in range(2):
            columns_t[i_col:i_col + columns_story[i_story] + 1, i_end, 0] = columns[
                                                                            i_col:i_col + columns_story[i_story] + 1,
                                                                            i_end, 0] + \
                                                                            plot_scale * edp[i_story + i_end, t]
        i_col = i_col + columns_story[i_story]

        beams_t[i_beam:i_beam + beams_floor[i_story] + 1, :, 0] = beams[i_beam:i_beam + beams_floor[i_story] + 1, :,
                                                                  0] + \
                                                                  plot_scale * edp[i_story + 1, t]
        i_beam = i_beam + beams_floor[i_story]

    column_collection = LineCollection(columns, color='darkgray', linestyle='-')
    _ = ax.add_collection(column_collection)

    beam_collection = LineCollection(beams, color='darkgray', linestyle='-')
    _ = ax.add_collection(beam_collection)

    column_collection = LineCollection(columns_t, color='k', linestyle='-')
    _ = ax.add_collection(column_collection)

    beam_collection = LineCollection(beams_t, color='k', linestyle='-')
    _ = ax.add_collection(beam_collection)

    _ = ax.axis('scaled')

    building_height = np.max(columns[:, :, 1])
    building_width = np.max(columns[:, :, 0])
    y_gap = 500
    x_gap = 380  # 100
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
                    beams[i_element, i_end, 0] = np.sum(bay_widths[:i_beam + i_end])
                i_element = i_element + 1

    # store the original geometry of each joint
    joints_x = np.array([np.sum(bay_widths[:i_beam]) for i_beam in range(n_bays + 1)])
    joints_y = np.array([np.sum(story_heights[:i_story + 1]) for i_story in range(n_stories)])
    joints_y = np.insert(joints_y, 0, 0, axis=0)  # add the hinge at column base
    [joints_x, joints_y] = np.meshgrid(joints_x, joints_y)

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

def get_beam_response(results_folder, beam_list, filenames):
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
    #                     'hinge_left'
    #                     'hinge_right'
    #
    # OUTPUTS
    #    beam_results = dictionary with all results for the beams, one key for each filename
    #

    beam_results = dict(keys=filenames)
    for file in filenames:
        beam_results[file] = np.zeros(beam_list.shape)

    n_stories, n_bays = beam_list.shape

    # Read results as 1d array
    for file in filenames:
        filepath = posixpath.join(results_folder, file + '.out')

        if file == 'hinge_left' or file == 'hinge_right':
            # read axial def, shear def, rotation for each hinge
            hinge_1d = np.loadtxt(filepath)
            _, n_cols = hinge_1d.shape
            axial_def = hinge_1d[:, 0:n_cols:3]
            shear_V = hinge_1d[:, 1:n_cols:3]
            rot = hinge_1d[:, 2:n_cols:3]

            # read maximum rotation for each hinge
            results_1d = np.max(abs(rot), axis=0)
        # elif file != 'hinge_left' and file != 'hinge_right':
        #     # read the response value at last time step (usually state of the fracture fiber)
        #     results_1d = np.loadtxt(filepath)[-1, :]
        else:
            # read the maximum response value in entire time history
            results_1d = np.max(abs(np.loadtxt(filepath)), axis=0)

        i_element = 0
        for i_story in range(n_stories):
            for i_beam in range(n_bays):
                if beam_list[i_story, i_beam] > 0:
                    beam_results[file][i_story, i_beam] = results_1d[i_element]
                    i_element += 1

    return beam_results


def get_pz_response(results_folder, beam_list, column_list, filenames):
    # Read response for panel zones, currently takes the maximum of the time history
    #
    # INPUTS
    #    results_folder = path to folder with the results of NLRHA
    #    beam_list      = 2D np.array with 1 or 0 for the beams that exist
    #    column_list    = 2D np.array with 1 or 0 for the columns that exist
    #    filenames      = list with any group of the following alternatives
    #                     'pz_rot'
    #
    # OUTPUTS
    #    pz_results = dictionary with all results for the panel zones
    #

    pz_results = dict(keys=filenames)
    for file in filenames:
        pz_results[file] = np.zeros(column_list.shape)

    n_stories, n_pier = column_list.shape

    # Read results as 1d array
    for file in filenames:
        filepath = posixpath.join(results_folder, file + '.out')

        res = np.loadtxt(filepath)
        results_1d = np.max(abs(res), axis=0)  # read maximum response for each pz

        i_element = 0
        for i_story in range(n_stories):
            for i_pier in range(n_pier):
                if beam_list[i_story, min(i_pier, n_pier - 2)] > 0 and (
                        column_list[i_story, i_pier] > 0 or column_list[i_story + 1, i_pier] > 0):
                    pz_results[file][i_story, i_pier] = results_1d[i_element]
                    i_element += 1

    return pz_results


def get_column_response(results_folder, beam_list, column_list, filenames):
    # Read response for columns, currently takes the maximum of the time history
    #
    # INPUTS
    #    results_folder = path to folder with the results of NLRHA
    #    beam_list      = 2D np.array with 1 or 0 for the beams that exist
    #    column_list    = 2D np.array with 1 or 0 for the columns that exist
    #    filenames      = list with any group of the following alternatives
    #                     'hinge_bot'
    #                     'hinge_top'
    #
    # OUTPUTS
    #    column_results = dictionary with all results for the columns, one key for each filename
    #

    column_results = dict(keys=filenames)
    for file in filenames:
        column_results[file] = np.zeros(column_list.shape)

    n_stories, n_pier = column_list.shape

    # Read results as 1d array
    for file in filenames:
        filepath = posixpath.join(results_folder, file + '.out')

        res = np.loadtxt(filepath)
        results_1d = np.max(abs(res), axis=0)  # read maximum response for each pz

        i_element = 0
        for i_story in range(n_stories):
            for i_pier in range(n_pier):
                if column_list[i_story, i_pier] > 0:  # jump if setbacks
                    if i_story == 0 or beam_list[
                        i_story - 1, min(i_pier, n_pier - 2)]:  # jump columns already created in atriums
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
        filepath = posixpath.join(results_folder, 'story' + str(1) + '_' + file + '.out')
        response = np.loadtxt(filepath)

        if file == 'disp':
            story_response['time'] = response[:, 0]
            response = response[:, 1]
        elif file == 'drift_env' or file == 'acc_env':
            response = response[2]

        for i_story in range(n_stories - 1):
            i_story = i_story + 1
            filepath = posixpath.join(results_folder, 'story' + str(i_story + 1) + '_' + file + '.out')
            res = np.loadtxt(filepath)

            if file == 'disp':
                res = res[:, 1]
            elif file == 'drift_env' or file == 'acc_env':
                res = res[2]

            response = np.vstack((response, res))

        story_response[file] = response

    return story_response


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


def plot_fractures_edp(ax, t, edp, joints_x, joints_y, frac_results, plot_scale=1, marker_size=50, add_legend=False, one_fracture_color='m',
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

    # Add the ground level displacement
    [_, n_pts] = edp.shape
    edp = np.insert(edp, 0, np.zeros((1, n_pts)), axis=0)

    # Add displacement to each joint index
    joints_x_t = joints_x.copy()
    for story_i in range(n_stories):
        joints_x_t[story_i, :] = joints_x_t[story_i, :] + plot_scale * edp[story_i, t] * np.ones(
            len(joints_x_t[story_i, :]))

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
    _ = ax.scatter(joints_x_top, joints_y_top, s=marker_size, color='tab:blue')

    # Plot annotations below the frame to show scale for all non-zero bins
    if add_legend:
        y_gap = -100
        y_between = -150
        _ = ax.scatter(joints_x_t[0,0] * 1/5, y_gap, s=marker_size, color='m')
        _ = ax.text(joints_x_t[0,0] * 1/5 + marker_size/4, y_gap - 50, 'Bottom fracture', size=18)

        _ = ax.scatter(joints_x_t[0,0] * 1/5, y_gap+y_between, s=marker_size, color='r')
        _ = ax.text(joints_x_t[0,0] * 1/5 + marker_size/4, y_gap - 50 + y_between, 'Top & Bottom fracture', size=18)


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
    respose_left[respose_left >= max_value] = max_value
    respose_right[respose_right >= max_value] = max_value

    # Review left side of all beams
    for story_i in range(n_stories):

        for bay_i in range(n_bays):
            col_i = bay_i

            marker_size = respose_left[story_i, bay_i] / max_value * max_marker_size
            _ = ax.scatter(joints_x[story_i + 1, col_i] + d_x, joints_y[story_i + 1, col_i], s=marker_size,
                           facecolors='none', color='m', alpha=0.9)

            # Review right side of all beams
    d_x = -d_x
    for story_i in range(n_stories):

        for bay_i in range(n_bays):
            col_i = bay_i + 1

            marker_size = respose_right[story_i, bay_i] / max_value * max_marker_size
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
    respose_left[respose_left >= max_value] = max_value
    respose_right[respose_right >= max_value] = max_value

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
            if respose_left[story_i, bay_i] > np.max(bins):
                curr_bin = len(bins)
            else:
                while respose_left[story_i, bay_i] > bins[curr_bin]:
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
            if respose_right[story_i, bay_i] > np.max(bins):
                curr_bin = len(bins)
            else:
                while respose_right[story_i, bay_i] > bins[curr_bin]:
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

    # Set all values greater than the maximum equal to the maximum
    respose_left[respose_left >= max_value] = max_value
    respose_right[respose_right >= max_value] = max_value

    # Marker sizes
    n_bins = len(bins)
    marker_size_bin = np.zeros(n_bins)
    for bin_i in range(n_bins - 1):
        marker_size_bin[bin_i + 1] = max_marker_size / (2 * (n_bins - 1)) * (1 + bin_i * 2)
    marker_size_bin[-1] = max_marker_size

    # Add the ground level displacement
    [_, n_pts] = edp.shape
    edp = np.insert(edp, 0, np.zeros((1, n_pts)), axis=0)

    # Add displacement to each joint index
    joints_x_t = joints_x.copy()
    for story_i in range(n_stories):
        joints_x_t[story_i, :] = joints_x_t[story_i, :] + plot_scale * edp[story_i, t] * np.ones(
            len(joints_x_t[story_i, :]))

    # Review left side of all beams
    for story_i in range(n_stories):

        for bay_i in range(n_bays):
            col_i = bay_i

            # Get the index of the correct bin for marker size
            curr_bin = 1
            if respose_left[story_i, bay_i] > np.max(bins):
                curr_bin = len(bins)
            else:
                while respose_left[story_i, bay_i] > bins[curr_bin]:
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
            if respose_right[story_i, bay_i] > np.max(bins):
                curr_bin = len(bins)
            else:
                while respose_right[story_i, bay_i] > bins[curr_bin]:
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
    respose_bot[respose_bot >= max_value] = max_value
    respose_top[respose_top >= max_value] = max_value

    # Review bottom side of all beams
    for story_i in range(n_stories):

        for pier_i in range(n_piers):
            marker_size = respose_bot[story_i, pier_i] / max_value * max_marker_size
            _ = ax.scatter(joints_x[story_i, pier_i], joints_y[story_i, pier_i] + d_y, s=marker_size,
                           facecolors='none', color='m', alpha=0.9)

    # Review top side of all beams
    d_y = -d_y
    for story_i in range(n_stories):

        for pier_i in range(n_piers):
            marker_size = respose_top[story_i, pier_i] / max_value * max_marker_size
            _ = ax.scatter(joints_x[story_i + 1, pier_i], joints_y[story_i + 1, pier_i] + d_y, s=marker_size,
                           facecolors='none', color='m', alpha=0.9)

    # Plot annotation below the frame to show scale
    y_gap = -50
    _ = ax.scatter(np.mean(joints_x[0]), y_gap, s=max_marker_size, facecolors='none', color='m', alpha=0.9)
    _ = ax.text(np.mean(joints_x[0]) + max_marker_size / 4, y_gap * 2, 'Size = ' + str(max_value), size=18)


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
    # beam rotation, column rotation, and panel zone rotation) and computes the FEMA 352 damage index per floor.
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