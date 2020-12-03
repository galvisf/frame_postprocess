from .base import *

def plot_building_at_t(t, edp, columns, beams, plot_scale, ax):
    ax.cla()

    [_, n_pts] = edp.shape
    edp = np.insert(edp, 0, np.zeros((1, n_pts)), axis=0)

    [n_columns, _, _] = columns.shape
    [n_beams, _, _] = beams.shape
    n_stories = int(n_columns - n_beams)
    n_bays = int(n_beams / n_stories)

    columns_t = columns.copy()
    beams_t = beams.copy()

    i_col = 0
    i_beam = 0
    for i_story in range(n_stories):
        for i_end in range(2):
            columns_t[i_col:i_col + n_bays + 2, i_end, 0] = columns[i_col:i_col + n_bays + 2, i_end, 0] + \
                                                            plot_scale * edp[i_story + i_end, t]
        i_col = i_col + n_bays + 1

        beams_t[i_beam:i_beam + n_bays + 1, :, 0] = beams[i_beam:i_beam + n_bays + 1, :, 0] + \
                                                    plot_scale * edp[i_story + 1, t]
        i_beam = i_beam + n_bays

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
    y_gap = 150
    x_gap = 100
    _ = ax.set_xlim(-x_gap, building_width + x_gap)
    _ = ax.set_ylim(-y_gap, building_height + y_gap)
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


def plot_flaw_size(joints_x, joints_y, a0, side):
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


def plot_fractures(joints_x, joints_y, frac_results):
    flange_locations = frac_results.keys()

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

    _ = ax.plot(joints_x_bot, joints_y_bot, 'o', color='m', alpha=0.9)
    _ = ax.plot(joints_x_both, joints_y_both, 'o', color='r', alpha=0.9)
    _ = ax.plot(joints_x_top, joints_y_top, 'o', color='tab:blue', alpha=0.9)


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

        if file != 'hinge_left' and file != 'hinge_right':
            results_1d = np.loadtxt(filepath)[-1, :]  # read the state of the fracture elements at last time step
        else:
            hinge_1d = np.loadtxt(filepath)  # read axial def, shear def, rotation for each hinge
            _, n_cols = hinge_1d.shape
            axial_def = hinge_1d[:, 0:n_cols:3]
            shear_V = hinge_1d[:, 1:n_cols:3]
            rot = hinge_1d[:, 2:n_cols:3]
            results_1d = np.max(abs(rot), axis=0)  # read maximum rotation for each hinge

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


def plot_beam_response(joints_x, joints_y, respose_left, respose_right, d_x=30, max_value=1, max_marker_size=300):
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
    _ = ax.text(np.mean(joints_x[0]) + max_marker_size / 4, y_gap * 4 / 3, 'Size = ' + str(max_value))


def plot_story_response(story_response_to_plot, story_heights, bay_widths,
                        x_ticks=np.array([0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]),
                        xlabel_text='Peak story drift ratio [%]'):
    data = np.vstack((story_response_to_plot, story_response_to_plot[-1]))
    heights = np.array([0])
    heights = np.hstack((heights, story_heights))

    # Scale to ensure parallel to building plot
    building_height = sum(story_heights)
    building_width = sum(bay_widths)
    y_gap = 150  # same as in building plot function
    x_gap = 100  # same as in building plot function
    scale_for_plot = (building_width) / np.max(data)

    _ = ax.step(data * scale_for_plot, np.cumsum(heights), linewidth=2, color='r')
    _ = ax.axis('scaled')

    # Formatting to ensure parallel to building plot
    _ = ax.set_xticks(x_ticks * scale_for_plot / 100)
    _ = ax.set_xticklabels(x_ticks)
    _ = ax.set_xlim(-x_gap, building_width + x_gap)
    _ = ax.set_ylim(-y_gap, building_height + y_gap)
    _ = ax.set_yticks(np.cumsum(heights))
    _ = ax.set_yticklabels(np.arange(len(heights)))

    _ = ax.set_ylabel('Floor number')
    _ = ax.set_xlabel(xlabel_text)
    _ = ax.grid(which='both', alpha=0.3)

