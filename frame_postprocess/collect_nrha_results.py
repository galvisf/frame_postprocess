from .base import *



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
            filepath = os.path.join(results_folder, 'story' + str(1) + '_drift.out')
        else:
            filepath = os.path.join(results_folder, 'story' + str(1) + '_' + file + '.out')
        try:
            response = np.loadtxt(filepath)
        except:
            print('ERROR IN FILE ' + filepath)
            return

        if file == 'drift_max':
            if response.ndim == 2:
                response = np.max(np.abs(response[:, 1]))  # remove time column

        if file == 'drift':
            if response.ndim == 2:
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
                filepath = os.path.join(results_folder, 'story' + str(i_story + 1) + '_drift.out')
            else:
                filepath = os.path.join(results_folder, 'story' + str(i_story + 1) + '_' + file + '.out')
            # print(filepath)

            try:
                res = np.loadtxt(filepath)
            except:
                print('ERROR IN FILE ' + filepath)
                return

            if file == 'disp' or file == 'drift':
                if res.ndim == 2:
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


def get_EDPstory_response(results_folder, n_stories, file, minrdrift=5e-4):
    # INPUTS
    #    results_folder = path to folder with the results of NLRHA
    #    n_stories      = int with the number of stories
    #    file           = list with any group of the following alternatives
    #
    #                     'drift_env: absolute drift envelope 2D np.array (n_story, 1) with scalar per story
    #                     'drift_env_p: positive dirft envelope 2D np.array (n_story, 1) with scalar per story
    #                     'drift_env_n: negative dirft envelope 2D np.array (n_story, 1) with scalar per story
    #
    #                     'acc_env': 2D np.array (n_story, 1) with scalar per story
    #                     'acc_env_p': positive dirft envelope 2D np.array (n_story, 1) with scalar per story
    #                     'acc_env_n': negative dirft envelope 2D np.array (n_story, 1) with scalar per story
    #
    #                     'drift_max: absolute drift envelope (from drift.out files) 2D np.array (n_story, 1) with scalar per story
    #                     'drift_max_p: absolute drift envelope (from drift.out files) 2D np.array (n_story, 1) with scalar per story
    #                     'drift_max_n: absolute drift envelope (from drift.out files) 2D np.array (n_story, 1) with scalar per story
    #
    #                     'rdrift_all': 2D np.array (n_story, 1) with scalar per story keeping the sign
    #                     'rdrift_all_abs: 2D np.array (n_story, 1) with scalar per story
    #                     'rdrift_max': scalar with maximum absolute residual for the building
    #
    #   minrdrift       = float as minimum value of residual drift to consider
    # OUTPUTS
    #    response = np.array with the response desired per story/floor
    #

    # Read results as 1d array
    if 'rdrift' in file or 'drift_max' in file:
        file_save = file
        file = 'drift'
    elif 'drift_env' in file:
        file_save = file
        file = 'drift_env'
    elif 'acc_env' in file:
        file_save = file
        file = 'acc_env'
    else:
        print('File name not supported')

    # Reads the first story/floor
    # (BREAKS DATA COLLECTION IF EMPTY ACC FILES, MEANING THE RHA DID NOT FINISH)
    if file == 'acc_env':
        neg_line = 0
        pos_line = 0
        last_line = 0

        try:
            filepath = os.path.join(results_folder, 'story' + str(0) + '_' + file + '.out')
            with open(filepath) as f:
                for line in f:
                    try:
                        float(line)  # only place if can convert to float (avoid blank spaces in the file)
                        if line == '\n':
                            last_line = last_line
                        else:
                            last_line = line
                    except:
                        last_line = last_line

                    aux = float(last_line)
                    if neg_line == 0:
                        neg_line = aux
                    elif pos_line == 0:
                        pos_line = aux
                    else:
                        last_line = aux
        except:
            response = 0
            return response

        if '_n' in file_save:
            response = np.array(neg_line)
        elif '_p' in file_save:
            response = np.array(pos_line)
        else:
            response = np.array(last_line)  # read last line as list of strings: ignores first entry (time)

    elif file == 'drift_env':
        neg_line = 0
        pos_line = 0
        last_line = 0

        try:
            filepath = os.path.join(results_folder, 'story' + str(1) + '_' + file + '.out')
            with open(filepath) as f:
                for line in f:
                    line = line.strip()
                    line = line.split('\n')[0]
                    try:
                        aux = float(line)  # only place if can convert to float (avoid blank spaces in the file)
                    except:
                        aux = 0

                    if neg_line == 0:
                        neg_line = aux
                    elif pos_line == 0:
                        pos_line = aux
                    else:
                        last_line = aux
        except:
            response = 0
            return response

        if '_n' in file_save:
            response = np.array(neg_line)
        elif '_p' in file_save:
            response = np.array(pos_line)
        else:
            response = np.array(last_line)  # read last line as list of strings: ignores first entry (time)

    else:
        # Find story with drift.out file available
        for i in range(n_stories):
            filepath = os.path.join(results_folder, 'story' + str(i + 1) + '_' + file + '.out')
            try:
                #                 response = pd.read_csv(filepath, header=None, sep=' ')
                #                 response = response.values
                with open(filepath) as f:
                    last_line = 0
                    for line in f:
                        prev_line = last_line
                        if file == 'drift':
                            try:
                                aux = line.split()
                                aux = [float(x) for x in
                                       aux]  # convert to list of floats, empty "line" gives an error here
                                # should be two cell vector because the output must include time or should not be a space
                                if len(aux) == 1 or line == '\n':
                                    last_line = last_line
                                else:
                                    last_line = line
                            except:
                                last_line = last_line
                        else:
                            last_line = line
                    if file == 'drift':
                        aux = prev_line.split()  # read second to last line in a time history since sometimes has errors
                    else:
                        aux = last_line.split()  # read last line as list of strings (drift_env)

                    aux = [float(x) for x in aux]  # convert to list of floats
                    response = np.array(np.abs(aux))
                i_story_worked = i + 1
                break
            except:
                 pass
                # print('MISSING: story' + str(i + 1) + '_' + file + '.out')

        # Check if results on every story are not consistent
        # (usually when the building collapses in the first step)
        if 'i_story_worked' in locals():
            filepath = os.path.join(results_folder, 'story' + str(i_story_worked) + '_' + file + '.out')
        else:
            print('ERROR COLLECTING DATA FOR:')
            print(results_folder)
            print('')
            return 0

        with open(filepath) as f:
            last_line = 0
            drift_max = 0
            drift_max_p = 0
            drift_max_n = 0
            for line in f:
                prev_line = last_line
                try:
                    aux = line.split()
                    aux = [float(x) for x in aux]  # convert to list of floats, empty "line" gives an error here
                    # should be two cell vector because the output must include time or should not be a space
                    if len(aux) == 1 or line == '\n':
                        last_line = last_line
                    else:
                        last_line = line
                except:
                    last_line = last_line

                aux = last_line.split()
                aux = [float(x) for x in aux]
                drift_max = np.max([np.abs(aux[1]), drift_max])
                drift_max_p = np.max([aux[1], drift_max_p])
                drift_max_n = np.min([aux[1], drift_max_n])

            if file_save == 'drift_max':
                res = np.array(drift_max)
            elif file_save == 'drift_max_p':
                res = np.array(drift_max_p)
            elif file_save == 'drift_max_n':
                res = np.array(drift_max_n)
            elif 'rdrift' in file_save:
                aux = prev_line.split()  # read second to last line in a time history since sometimes has errors
                aux = [float(x) for x in aux]  # convert to list of floats
                if '_abs' in file_save or '_max' in file_save:
                    res = np.array(np.abs(aux[1]))  # ignores first entry (time)
                else:
                    res = np.array(aux[1])  # ignores first entry (time)

            if file_save == 'rdrift_all_abs' or file_save == 'rdrift_max':
                res = max(res, minrdrift)
            elif 'rdrift' in file_save:
                if res < 0:
                    res = min(res, -minrdrift)
                else:
                    res = max(res, minrdrift)
            response = res

    # Reads and append the results of the remaining stories/floors
    if file == 'acc_env':
        for i_floor in range(n_stories):
            filepath = os.path.join(results_folder, 'story' + str(i_floor) + '_' + file + '.out')
            #             res = np.loadtxt(filepath)
            #             res = pd.read_csv(filepath, header=None, sep=' ')
            #             res = res.values
            with open(filepath) as f:
                neg_line = 0
                pos_line = 0
                last_line = 0
                for line in f:
                    try:
                        float(line)  # only place if can convert to float (avoid blank spaces in the file)
                        # should not be a space
                        if line == '\n':
                            last_line = last_line
                        else:
                            last_line = line
                    except:
                        last_line = last_line

                    aux = float(last_line)
                    if neg_line == 0:
                        neg_line = aux
                    elif pos_line == 0:
                        pos_line = aux
                    else:
                        last_line = aux

                if '_n' in file_save:
                    res = np.array(neg_line)
                elif '_p' in file_save:
                    res = np.array(pos_line)
                else:
                    res = np.array(last_line)  # read last line as list of strings: ignores first entry (time)
            res
            response = np.vstack((response, res))
    else:
        for i_story in range(n_stories - 1):
            i_story = i_story + 1
            filepath = os.path.join(results_folder, 'story' + str(i_story + 1) + '_' + file + '.out')

            if file == 'drift':
                try:
                    # Check if drift.out file exist (some runs are not producing this output for some stories)
                    # res = pd.read_csv(filepath, header=None, sep=' ')
                    # res = res.values
                    with open(filepath) as f:
                        last_line = 0
                        drift_max = 0
                        drift_max_p = 0
                        drift_max_n = 0
                        for line in f:
                            prev_line = last_line
                            try:
                                aux = line.split()
                                aux = [float(x) for x in
                                       aux]  # convert to list of floats, empty "line" gives an error here
                                # should be two cell vector because the output must include time or should not be a space
                                if len(aux) == 1 or line == '\n':
                                    last_line = last_line
                                else:
                                    last_line = line
                            except:
                                last_line = last_line

                            aux = last_line.split()
                            aux = [float(x) for x in aux]
                            drift_max = np.max([np.abs(aux[1]), drift_max])
                            drift_max_p = np.max([aux[1], drift_max_p])
                            drift_max_n = np.min([aux[1], drift_max_n])

                        if file_save == 'drift_max':
                            res = np.array(drift_max)
                        elif file_save == 'drift_max_p':
                            res = np.array(drift_max_p)
                        elif file_save == 'drift_max_n':
                            res = np.array(drift_max_n)
                        elif 'rdrift' in file_save:
                            aux = prev_line.split()  # read second to last line in a time history since sometimes has errors
                            aux = [float(x) for x in aux]  # convert to list of floats
                            if '_abs' in file_save or '_max' in file_save:
                                res = np.array(np.abs(aux[1]))  # ignores first entry (time)
                            else:
                                res = np.array(aux[1])  # ignores first entry (time)

                    i_story_worked = i_story + 1
                except:
                    # If the drift.out file does not exist for this story, take the previous story
                    print('MISSING: story' + str(
                        i_story + 1) + '_' + file + '.out, TAKING previous story that worked: story' + str(
                        i_story_worked))
                    filepath = os.path.join(results_folder, 'story' + str(i_story_worked) + '_' + file + '.out')
                    # res = pd.read_csv(filepath, header=None, sep=' ')
                    # res = res.values
                    with open(filepath) as f:
                        last_line = 0
                        drift_max = 0
                        drift_max_p = 0
                        drift_max_n = 0
                        for line in f:
                            prev_line = last_line
                            try:
                                aux = line.split()
                                aux = [float(x) for x in
                                       aux]  # convert to list of floats, empty "line" gives an error here
                                # should be two cell vector because the output must include time or should not be a space
                                if len(aux) == 1 or line == '\n':
                                    last_line = last_line
                                else:
                                    last_line = line
                            except:
                                last_line = last_line

                            aux = last_line.split()
                            aux = [float(x) for x in aux]
                            drift_max = np.max([np.abs(aux[1]), drift_max])
                            drift_max_p = np.max([aux[1], drift_max_p])
                            drift_max_n = np.min([aux[1], drift_max_n])

                        if file_save == 'drift_max':
                            res = np.array(drift_max)
                        elif file_save == 'drift_max_p':
                            res = np.array(drift_max_p)
                        elif file_save == 'drift_max_n':
                            res = np.array(drift_max_n)
                        elif 'rdrift' in file_save:
                            aux = prev_line.split()  # read second to last line in a time history since sometimes has errors
                            aux = [float(x) for x in aux]  # convert to list of floats
                            if '_abs' in file_save or '_max' in file_save:
                                res = np.array(np.abs(aux[1]))  # ignores first entry (time)
                            else:
                                res = np.array(aux[1])  # ignores first entry (time)

            else:  # drift_env.out

                # res = pd.read_csv(filepath, header=None, sep=' ')
                # res = res.values
                neg_line = 0
                pos_line = 0
                last_line = 0
                with open(filepath) as f:
                    for line in f:
                        line = line.strip()
                        line = line.split('\n')[0]
                        try:
                            aux = float(line)  # only place if can convert to float (avoid blank spaces in the file)
                        except:
                            aux = 0

                        if neg_line == 0:
                            neg_line = aux
                        elif pos_line == 0:
                            pos_line = aux
                        else:
                            last_line = aux

                    if '_n' in file_save:
                        res = np.array(neg_line)
                    elif '_p' in file_save:
                        res = np.array(pos_line)
                    else:
                        res = np.array(last_line)  # read last line as list of strings: ignores first entry (time)

            # Minimum RID = minrdrift to avoid numerical issues when pelicun fits a probabilistic model
            if file_save == 'rdrift_all_abs' or file_save == 'rdrift_max':
                res = max(res, minrdrift)
            elif 'rdrift' in file_save:
                if res < 0:
                    res = min(res, -minrdrift)
                else:
                    res = max(res, minrdrift)

            # Save the maximum across floors or results per floor
            if file_save == 'rdrift_max':
                response = np.max([response, res])
            else:
                response = np.vstack((response, res))

    return response


def get_DSC(results_folder, n_connections):
    # Read response for each flange in each connection and interpretes the damage state of the connection per FEMAP58
    #
    # INPUTS
    #    results_folder = path to folder with the results of NLRHA
    #
    # OUTPUTS
    #    DSC            = 1D np.array with the DS for each connection starting with all the
    #                     left connection in each beam and then all the right connections.
    #                     DS0: No damage
    #                     DS1: Fracture of the bottom flange
    #                     DS2: Fracture of the top flange
    #                     DS3: Fracture of both flanges
    #

    # Left connection
    file = 'frac_LB'
    filepath = os.path.join(results_folder, file + '.out')
    with open(filepath) as f:
        last_line = 0
        prev_line = 0
        pp_line = 0
        for line in f:
            ppp_line = pp_line
            pp_line = prev_line
            prev_line = last_line
            if line == '\n':
                last_line = last_line
            else:
                last_line = line
        aux = last_line.split()  # read second to last line in a time history since sometimes has errors
        # only keeps set of results that include all connections (considering last 4 lines)
        if len(aux) != n_connections:
            aux = prev_line.split()  # read second to last line in a time history since sometimes has errors
            if len(aux) != n_connections:
                aux = pp_line.split()  # read second to last line in a time history since sometimes has errors
                if len(aux) != n_connections:
                    aux = ppp_line.split()  # read second to last line in a time history since sometimes has errors
        aux = [float(x) for x in aux]  # convert to list of floats
        frac_LB = np.abs(aux)

    file = 'frac_LT'
    filepath = os.path.join(results_folder, file + '.out')
    with open(filepath) as f:
        last_line = 0
        prev_line = 0
        pp_line = 0
        for line in f:
            ppp_line = pp_line
            pp_line = prev_line
            prev_line = last_line
            if line == '\n':
                last_line = last_line
            else:
                last_line = line
        aux = last_line.split()  # read second to last line in a time history since sometimes has errors
        # only keeps set of results that include all connections (considering last 4 lines)
        if len(aux) != n_connections:
            aux = prev_line.split()  # read second to last line in a time history since sometimes has errors
            if len(aux) != n_connections:
                aux = pp_line.split()  # read second to last line in a time history since sometimes has errors
                if len(aux) != n_connections:
                    aux = ppp_line.split()  # read second to last line in a time history since sometimes has errors
        aux = [float(x) for x in aux]  # convert to list of floats
        frac_LT = np.abs(aux)
    frac_LT = frac_LT * 2

    frac_L = frac_LB + frac_LT

    # Right connection
    file = 'frac_RB'
    filepath = os.path.join(results_folder, file + '.out')
    with open(filepath) as f:
        last_line = 0
        prev_line = 0
        pp_line = 0
        for line in f:
            ppp_line = pp_line
            pp_line = prev_line
            prev_line = last_line
            if line == '\n':
                last_line = last_line
            else:
                last_line = line
        aux = last_line.split()  # read second to last line in a time history since sometimes has errors
        # only keeps set of results that include all connections (considering last 4 lines)
        if len(aux) != n_connections:
            aux = prev_line.split()  # read second to last line in a time history since sometimes has errors
            if len(aux) != n_connections:
                aux = pp_line.split()  # read second to last line in a time history since sometimes has errors
                if len(aux) != n_connections:
                    aux = ppp_line.split()  # read second to last line in a time history since sometimes has errors
        aux = [float(x) for x in aux]  # convert to list of floats
        frac_RB = np.abs(aux)
    file = 'frac_RT'
    filepath = os.path.join(results_folder, file + '.out')
    with open(filepath) as f:
        last_line = 0
        prev_line = 0
        pp_line = 0
        for line in f:
            ppp_line = pp_line
            pp_line = prev_line
            prev_line = last_line
            if line == '\n':
                last_line = last_line
            else:
                last_line = line
        aux = last_line.split()  # read second to last line in a time history since sometimes has errors
        # only keeps set of results that include all connections (considering last 4 lines)
        if len(aux) != n_connections:
            aux = prev_line.split()  # read second to last line in a time history since sometimes has errors
            if len(aux) != n_connections:
                aux = pp_line.split()  # read second to last line in a time history since sometimes has errors
                if len(aux) != n_connections:
                    aux = ppp_line.split()  # read second to last line in a time history since sometimes has errors
        aux = [float(x) for x in aux]  # convert to list of floats
        frac_RT = np.abs(aux)
    frac_RT = frac_RT * 2

    frac_R = frac_RB + frac_RT

    DSC = np.hstack((frac_L, frac_R))

    return DSC


def get_DSsplice(results_folder, splice_frac_strain, n_splices):
    # Read response for each flange in each connection and interpretes the damage state of the connection per FEMAP58
    #
    # INPUTS
    #    results_folder     = path to folder with the results of NLRHA
    #    splice_frac_strain = strain limit to judge that fracture occured in the splice
    #
    # OUTPUTS
    #    DSsplice           = 1D np.array with the DS for each connection starting with all the
    #                         left connection in each beam and then all the right connections.
    #                         DS0: No damage
    #                         DS1: Fracture of splice weld in either side
    #

    # Inputs
    file = 'ss_splice'

    filepath = os.path.join(results_folder, file + '.out')
    with open(filepath) as f:
        max_res = np.zeros(2*n_splices)
        last_line = 0
        for line in f:
            prev_line = last_line
            try:
                aux = line.split()
                aux = [abs(float(x)) for x in aux]  # convert to list of floats, empty "line" gives an error here
                if len(aux) != 2*n_splices: # only keeps set of results that include all splices (stress and strain)
                    last_line = last_line
                else:
                    last_line = line
                    max_res = np.max(max_res, aux, axis=0)
            except:
                last_line = last_line
        # Take the last value
        # aux = prev_line.split()  # read second to last line in a time history since sometimes has errors
        # aux = [float(x) for x in aux]  # convert to list of floats
        # data_1d = np.abs(aux)

        # Take the max value in the history
        data_1d = max_res
    n_cols = len(data_1d)

    # extract strain
    strain_splices = data_1d[1:n_cols:2]

    # get boolean for fracture if excesive strain
    DSsplice = np.zeros(len(strain_splices))
    DSsplice[strain_splices > splice_frac_strain] = 1

    return DSsplice


def collect_gmset_response(stripe_folder_path, beam_list, fracElement, dir_i, spliceElement, splice_list, column_list,
                           drift_out='abs', rdrift_out='max', minrdrift=5e-4, splice_frac_strain=60 * 2 / 29000):
    # Creates a table per stripe with the peak responses per story/floor
    #
    # INPUTS
    #    stripe_folder_path = path to find the results for each ground motions
    #    beam_list          = 2D np.array with 1 or 0 for the beams that exist
    #    fracElement        = true : collects damage state for each connection
    #                         false: skip collection of connection damage state
    #    dir_i              = Code used to identify direction for EDP file format
    #                         1: denotes X
    #                         2: denotes Y
    #    spliceElement      = boolean to collect or not splice damage states
    #    splice_list        = 2D np.array with 1 or 0 for the stories where splices exist
    #    column_list        = list of 2D np.array indicating which columns exist
    #    drift_out          = Method to output peak drift
    #                         -> 'abs' = multiple columns with the peak absolute value for each floor
    #                         -> 'both' = multiple columns with the peak positive an negative value for each floor
    #    rdrift_out         = Method to output residual drift
    #                         -> 'max' = single column with the maximum residual across floors
    #                         -> 'all_abs' = multiple columns with the residual absolute value for each floor
    #                         -> 'all' = multiple columns with the residual for each floor with its sign
    #    minrdrift          = float as minimum value of residual drift to consider
    #    splice_frac_strain = strain limit to judge that fracture occured in the splice
    #
    # OUTPUT
    #    response_matrix    = pd.DataFrame with all the results (columns) for each ground motion (rows) in this stripe
    #

    n_stories, n_bays = beam_list.shape

    gm_ids = os.listdir(stripe_folder_path)
    n_gms = len(gm_ids)

    # Define column names for dataframe
    column_names = []
    column_names.append('EndCriteria')
    if drift_out == 'abs':
        for i_story in range(n_stories):
            column_names.append('1-PID-' + str(i_story + 1) + '-' + str(dir_i))
    else:
        for i_story in range(n_stories):
            column_names.append('1-PIDp-' + str(i_story + 1) + '-' + str(dir_i))
        for i_story in range(n_stories):
            column_names.append('1-PIDn-' + str(i_story + 1) + '-' + str(dir_i))
    if 'all' in rdrift_out:
        for i_story in range(n_stories):
            column_names.append('1-RID-' + str(i_story + 1) + '-' + str(dir_i))
    else:
        column_names.append('1-RID-1' + '-' + str(dir_i))
    for i_floor in range(n_stories):
        column_names.append('1-PFA-' + str(i_floor) + '-' + str(dir_i))
    column_names.append('1-PFA-' + str(n_stories) + '-' + str(dir_i))

    if fracElement:
        for i_floor in range(n_stories):
            for i_beam in range(n_bays):
                if beam_list[i_floor, i_beam] > 0:
                    column_names.append('1-DSC-' + str(i_floor + 1) + '-' + "{0:0=4d}".format(
                        dir_i * 1000 + i_beam * 10 + 1))  # DSC: Damage State Connection (left side)
        for i_floor in range(n_stories):
            for i_beam in range(n_bays):
                if beam_list[i_floor, i_beam] > 0:
                    column_names.append('1-DSC-' + str(i_floor + 1) + '-' + "{0:0=4d}".format(
                        dir_i * 1000 + i_beam * 10 + 2))  # DSC: Damage State Connection (right side)

    if spliceElement:
        n_stories, n_pier = column_list.shape
        for i_pier in range(n_pier):
            for i_story in range(n_stories):
                if splice_list[i_story, i_pier] > 0:
                    # jump if no splice in this column segment. The splice_list array already accounts for setbacks, atriums or missing columns
                    column_names.append('1-DSS-' + str(i_story + 1) + '-' + "{0:0=3d}".format(
                        dir_i * 100 + i_pier))  # DSC: Damage State Splice

    # print(len(column_names))
    # print(column_names)

    # collect response per story/floor as a list of arrays, each entry in the list is on gm
    response = []
    gm_ids = os.listdir(stripe_folder_path)
    removeGMlist = []
    for j in range(n_gms):
        # print(gm_ids[j])
        results_folder = os.path.join(stripe_folder_path, gm_ids[j])
        pfa_gm = get_EDPstory_response(results_folder, n_stories, 'acc_env')
        rdrift_gm = get_EDPstory_response(results_folder, n_stories, 'rdrift_' + rdrift_out, minrdrift=minrdrift)
        if drift_out == 'abs':
            pid_gm = get_EDPstory_response(results_folder, n_stories, 'drift_env')
            if type(pid_gm) == int:
                pid_gm = get_EDPstory_response(results_folder, n_stories, 'drift_max')
        else:
            pid_gm_p = get_EDPstory_response(results_folder, n_stories, 'drift_env_p')
            if type(pid_gm_p) == int:
                pid_gm_p = get_EDPstory_response(results_folder, n_stories, 'drift_max_p')
            pid_gm_n = get_EDPstory_response(results_folder, n_stories, 'drift_env_n')
            if type(pid_gm_n) == int:
                pid_gm_n = get_EDPstory_response(results_folder, n_stories, 'drift_max_n')
            pid_gm = np.hstack((pid_gm_p.flatten(), pid_gm_n.flatten()))

        if type(pfa_gm) == int:  # did not finish RHA, so skip the ground motion
            print('Did not finish GM (ACC ZERO): ' + results_folder)
            print()
            removeGMlist.append(j)
        elif type(rdrift_gm) == int:  # did not finish RHA, so skip the ground motion
            print('Did not finish GM (RDRIFT ZERO): ' + results_folder)
            print()
            removeGMlist.append(j)
        elif type(pid_gm) == int:  # did not finish RHA, so skip the ground motion
            print('Did not finish GM (DRIFT ZERO): ' + results_folder)
            print()
            removeGMlist.append(j)
        else:
            # pid_gm = get_EDPstory_response(results_folder, n_stories, 'drift_env')
            # try:
            # rdrift_gm = get_EDPstory_response(results_folder, n_stories, 'rdrift_' + rdrift_out, minrdrift=minrdrift)
            # except:
            #     print('ERROR drift for ' + gm_ids[j])

            if fracElement:
                dsc_gm = get_DSC(results_folder, np.sum(beam_list))
                # print(np.sum(beam_list)*2)
                # print(len(dsc_gm.flatten()))
            if spliceElement:
                dssplice_gm = get_DSsplice(results_folder, splice_frac_strain, np.sum(splice_list))
                # print(np.sum(splice_list))
                # print(len(dssplice_gm.flatten()))

            filepath = os.path.join(results_folder, 'MSA.txt')
            try:
                maxDrift_wcollapse = np.loadtxt(filepath)
            except:
                with open(filepath) as f:
                    for line in f:
                        maxDrift_wcollapse = line.strip()

            if type(maxDrift_wcollapse) == str:
                if  maxDrift_wcollapse == 'Collapsed':
                    endCriteria = 'MaxDrift'
                else:
                    endCriteria = 'nonCollapse'

            else:

                # Find unknown errors
                try:
                    np.max(np.abs(pid_gm))
                except:
                    print(pid_gm)
                    print('UNKNOWN ERROR: ' + results_folder)

                # Define endCriteria
                if (maxDrift_wcollapse > 0.099) and (np.max(np.abs(pid_gm)) > 0.07):
                    # Maximum drift reached during the analysis
                    endCriteria = 'MaxDrift'
                #                 response_gm = np.hstack((endCriteria, np.zeros(pid_gm.shape).flatten(), np.zeros(rdrift_gm.shape).flatten(), \
                #                                          np.zeros(pfa_gm.shape).flatten(), np.zeros(dsc_gm.shape).flatten()))
                elif (maxDrift_wcollapse > 0.099) and (np.max(np.abs(pid_gm)) < 0.07):
                    # Inconvergence
                    endCriteria = 'Inconvergence'
                #                 response_gm = np.hstack((endCriteria, np.zeros(pid_gm.shape).flatten(), np.zeros(rdrift_gm.shape).flatten(), \
                #                                          np.zeros(pfa_gm.shape).flatten(), np.zeros(dsc_gm.shape).flatten()))
                else:
                    # Non collapse
                    endCriteria = 'nonCollapse'
                #                 response_gm = np.hstack((endCriteria, pid_gm.flatten(), rdrift_gm.flatten(), pfa_gm.flatten(), dsc_gm.flatten()))

            if fracElement and spliceElement:
                response_gm = np.hstack(
                    (endCriteria, pid_gm.flatten(), rdrift_gm.flatten(), pfa_gm.flatten(), dsc_gm.flatten(),
                     dssplice_gm.flatten()))
            elif fracElement:
                response_gm = np.hstack(
                    (endCriteria, pid_gm.flatten(), rdrift_gm.flatten(), pfa_gm.flatten(), dsc_gm.flatten()))
            elif spliceElement:
                response_gm = np.hstack(
                    (endCriteria, pid_gm.flatten(), rdrift_gm.flatten(), pfa_gm.flatten(), dssplice_gm.flatten()))
            else:
                try:
                    pid_gm.flatten()
                except:
                    print('pid_gm')
                    print(results_folder)
                try:
                    rdrift_gm.flatten()
                except:
                    print('pid_gm')
                    print(results_folder)
                try:
                    pfa_gm.flatten()
                except:
                    print('pid_gm')
                    print(results_folder)

                response_gm = np.hstack((endCriteria, pid_gm.flatten(), rdrift_gm.flatten(), pfa_gm.flatten()))

            # print(response_gm)
            # print(len(response_gm))
            # print('DONE: ' + gm_ids[j])
            response.append(response_gm)

    # save peak idr matrix
    gm_ids = np.delete(gm_ids, removeGMlist)  # remove the gm that did not finish RHA
    # print(len(response))
    # print(len(gm_ids))
    response_matrix = pd.DataFrame(response, columns=column_names, index=gm_ids)

    return response_matrix


def collect_endState_singleDir_response(model_name_all, save_results_folder_all, stripe_folders_all, msa_folders_all, beam_list_all,
                               column_list_all, pz_list_all, splice_all, colSplice_all, case_i):
    # INPUTS
    # All the inputs include information per case (different from the EDP collector that breaks each case into independent jobs per stripe
    #    model_name_all           = list of str with the case name to collect results from
    #    save_results_folder_all  = list of str with path to save results
    #    stripe_folders_all       = list of list with the folder name of each stripe
    #    msa_folders_all          = list eith the path_to_results
    #    beam_list_all          = list of 2D np.array indicating which beams exist in the X frame
    #    column_list_all        = list of 2D np.array indicating which columns exist in the X frame
    #    pz_list_all            = list of 2D np.array indicating which pz exist in the X frame
    #    splice_all               = list of boolean if splice are considered or ignored
    #    colSplice_all          = list of 2D np.array indicating which stories have a splice in the X frame
    #

    # Parse case to execute
    model_name    = model_name_all[case_i]
    save_results_folder = save_results_folder_all[case_i]
    stripe_folders= stripe_folders_all[case_i]
    msa_folders   = msa_folders_all[case_i]
    beam_list     = beam_list_all[case_i]
    column_list   = column_list_all[case_i]
    pz_list       = pz_list_all[case_i]
    splice        = splice_all[case_i]
    if splice == 1:
        colSplice = colSplice_all[case_i]

    n_stripes = len(stripe_folders)
    # Collect end state for every gm in every return period for BOTH DIRECTIONS

    print('------- ' + model_name + ' -------')

    # Select frame geometry matrices
    results_filename = os.path.join(save_results_folder, model_name + '.h5')

    # # count panel zones
    n_stories, n_pier = column_list.shape
    num_pz = 0
    for i_story in range(n_stories):
        for i_pier in range(n_pier):
            if ((column_list[min(i_story + 1, n_stories-1), i_pier] == 1) or
                    ((column_list[i_story, i_pier] == 1 )) and
                    (beam_list[i_story, i_pier - 1])):
                existPZ = True
            elif ((column_list[min(i_story + 1, n_stories-1), i_pier] == 1) or
                    ((column_list[i_story, i_pier] == 1 ) and
                     (beam_list[i_story, min(i_pier, n_pier -2)]))):
                existPZ = True
            else:
                existPZ = False

            if existPZ:
                num_pz += 1
    print('num_pz='+str(num_pz))

    # Removes existing file
    if os.path.isfile(results_filename):
        os.remove(results_filename)
        print(results_filename + ' already exists, so deleted it')

    # if True (Collects only data for those building without data)
    if not os.path.isfile(results_filename):

        # Collect results and store in HDF file
        with h5py.File(results_filename, 'w') as hf:
            # prepare data groups per return period
            for group in stripe_folders:
                _ = hf.create_group('/' + group)

            # collect bldg response for each gm in each stripe
            for i in range(n_stripes):
                stripe_folder_path = os.path.join(msa_folders, stripe_folders[i])

                print('RP = ' + str(stripe_folders[i]) + 'years')
                # print(stripe_folder_path)

                gm_ids = os.listdir(stripe_folder_path)
                for j in range(len(gm_ids)):
                    # print(gm_ids[j])

                    # collect results for this gm
                    results_gm = os.path.join(stripe_folder_path, gm_ids[j])

                    # check if acc results available (gm finished?)
                    pfa_gm = get_EDPstory_response(results_gm, n_stories, 'acc_env')
                    if type(pfa_gm) == int:  # did not finish RHA, so skip the ground motion
                        print('Did not finish GM' + str(gm_ids[j]))
                    else:
                        #    Panel zones
                        pz_response = get_pz_response(results_gm, pz_list, ['all_disp', 'pz_rot'])
                        #    beams and columns
                        column_response = get_column_response(results_gm, column_list, ['hinge_bot','hinge_top'])
                        beam_plas_rot = get_beam_response(results_gm, beam_list, ['hinge_left', 'hinge_right'])
                        frac_simulated  = get_beam_response(results_gm, beam_list, ['frac_LB','frac_LT','frac_RB','frac_RT'])
                        #    Splices
                        if splice == 1:
                            splice_response = get_splice_response(results_gm, colSplice, column_list, ['ss_splice'],
                                              res_type='Max', def_desired='strain')
                            splice_frac = splice_response['ss_splice'] > 2*60/29000

                        # create gm group
                        rp_group = hf['/' + stripe_folders[i]]
                        gm_record_group = rp_group.create_group(gm_ids[j])

                        # Save in h5 file's building_group
                        key = 'all_disp'
                        _ = gm_record_group.create_dataset(key, data=pz_response[key])
                        key = 'pz_rot'
                        _ = gm_record_group.create_dataset(key, data=pz_response[key])
                        key = 'hinge_bot'
                        _ = gm_record_group.create_dataset(key, data=column_response[key])
                        key = 'hinge_top'
                        _ = gm_record_group.create_dataset(key, data=column_response[key])
                        key = 'hinge_left'
                        _ = gm_record_group.create_dataset(key, data=beam_plas_rot[key])
                        key = 'hinge_right'
                        _ = gm_record_group.create_dataset(key, data=beam_plas_rot[key])
                        key = 'frac_LB'
                        _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                        key = 'frac_LT'
                        _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                        key = 'frac_RB'
                        _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                        key = 'frac_RT'
                        _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                        if splice == 1:
                            key = 'ss_splice'
                            _ = gm_record_group.create_dataset(key, data=splice_response[key])
                            key = 'splice_frac'
                            _ = gm_record_group.create_dataset(key, data=splice_frac)


def collect_XandY_response(model_name_all, stripe_folder_all, save_results_folder_all, msa_folders_all, beam_list_x_all,
                           beam_list_y_all, fracElement, spliceElement_all, splice_list_x_all, splice_list_y_all,
                           column_list_x_all,
                           column_list_y_all, minrdrift, splice_frac_strain, case_i):
    # INPUTS
    # Collects the EDP results considering each stripe of each case as an independent job
    #    model_name_all           = list of str with the case name to collect results from
    #    stripe_folder_all        = list of str with the foldername of the stripe to collect results from
    #    save_results_folder_all  = list of str with path to save results
    #    msa_folders_all          = list of list [path_to_results_X, path_to_results_Y]
    #    beam_list_x_all          = list of 2D np.array indicating which beams exist in the X frame
    #    beam_list_Y_all          = list of 2D np.array indicating which beams exist in the Y frame
    #    fracElement              = true  -> collect connections DS
    #                               false -> does NOT collect connections DS
    #
    #    spliceElement_all        = 1 -> collect splice data
    #                               0 -> do not collect splice data
    #    splice_list_x_all        = list of 2D np.array indicating the pier and story with splice in the X frame
    #    splice_list_y_all        = list of 2D np.array indicating the pier and story with splice in the Y frame
    #    column_list_x_all        = list of 2D np.array indicating which columns exist in the X frame
    #    column_list_y_all        = list of 2D np.array indicating which column exist in the X frame
    #    minrdrift                = minimum residual drift to collect
    #    splice_frac_strain       = strain limit for deciding fracture occured on splices
    #

    # Parse case to execute
    model_name = model_name_all[case_i]
    stripe_folder = stripe_folder_all[case_i]
    save_results_folder = save_results_folder_all[case_i]
    msa_folders = msa_folders_all[case_i]
    beam_list_x = beam_list_x_all[case_i]
    beam_list_y = beam_list_y_all[case_i]

    spliceElement = spliceElement_all[case_i]
    column_list_x = column_list_x_all[case_i]
    column_list_y = column_list_y_all[case_i]
    splice_list_x = splice_list_x_all[case_i]
    splice_list_y = splice_list_y_all[case_i]

    # Define path to save results
    results_filename = os.path.join(save_results_folder, 'EDP_' + model_name + '_' + stripe_folder + '.csv')

    #### collect results on X ####
    dir_i = 0
    dirCase = 'X'
    # print(stripe_folder + ' ' + dirCase + ': start')
    stripe_folder_path = os.path.join(msa_folders[dir_i], stripe_folder)
    # try:
    resultsX = collect_gmset_response(stripe_folder_path, beam_list_x, fracElement, dir_i + 1, spliceElement,
                                      splice_list_x, column_list_x, minrdrift=minrdrift,
                                      splice_frac_strain=splice_frac_strain)
    # except:
    #     print('ERROR: ' + model_name + '_' + stripe_folder + ' ' + dirCase)

    #### collect results on Y ####
    dir_i = 1
    dirCase = 'Y'
    # print(stripe_folder + ' ' + dirCase + ': start')
    stripe_folder_path = os.path.join(msa_folders[dir_i], stripe_folder)
    # try:
    resultsY = collect_gmset_response(stripe_folder_path, beam_list_y, fracElement, dir_i + 1, spliceElement,
                                      splice_list_y, column_list_y, minrdrift=minrdrift,
                                      splice_frac_strain=splice_frac_strain)
    # except:
    #     print('ERROR: ' + model_name + '_' + stripe_folder + ' ' + dirCase)

    #### consolidate in a unique table ####
    # Get RSN for each ground motion
    record_namesX = resultsX.index
    record_namesY = resultsY.index
    rsnX = []
    for i in range(len(record_namesX)):
        rsnX.append(record_namesX[i].split('_')[0])
    rsnX = np.array(rsnX)
    rsnY = []
    for i in range(len(record_namesY)):
        rsnY.append(record_namesY[i].split('_')[0])
    rsnY = np.array(rsnY)

    # Replace dataframe indexes by RSN
    resultsX.index = rsnX
    resultsY.index = rsnY

    # Join the tables to include X and Y results
    results = pd.concat([resultsX, resultsY], axis=1, join="inner")

    # Merge EndCriteria columns
    endCriteria = results['EndCriteria'].values
    endCriteriaTotal = []
    for i in range(len(endCriteria)):
        if endCriteria[i, 0] == 'MaxDrift' or endCriteria[i, 1] == 'MaxDrift':
            endCriteriaTotal.append('MaxDrift')
        elif endCriteria[i, 0] == 'Inconvergence' or endCriteria[i, 1] == 'Inconvergence':
            endCriteriaTotal.append('Inconvergence')
        else:
            endCriteriaTotal.append('nonCollapse')
    results = results.drop('EndCriteria', axis=1)  # drop EndCriteria per direction
    results.insert(0, 'EndCriteriaX', endCriteria[:, 0])  # Insert EndCriteriaX with proper column name
    results.insert(0, 'EndCriteriaY', endCriteria[:, 1])  # Insert EndCriteriaY with proper column name
    results.insert(0, 'EndCriteria', endCriteriaTotal)  # Insert combined EndCriteria

    results.to_csv(results_filename)



def collect_singleDir_response(model_name_all, stripe_folder_all, save_results_folder_all, msa_folder_all, beam_list_all,
                           column_list_all, fracElement, splice_all, splice_list_all,
                           minrdrift, splice_frac_strain, drift_out, rdrift_out, case_i):
    # INPUTS
    # Collects the EDP results considering each stripe of each case as an independent job
    #    model_name_all           = list of str with the case name to collect results from
    #    stripe_folder_all        = list of str with the foldername of the stripe to collect results from
    #    save_results_folder_all  = list of str with path to save results
    #    msa_folder_all          = list of list [path_to_results_X, path_to_results_Y]
    #    beam_list_x_all          = list of 2D np.array indicating which beams exist in the X frame
    #    beam_list_Y_all          = list of 2D np.array indicating which beams exist in the Y frame
    #    fracElement              = true  -> collect connections DS
    #                               false -> does NOT collect connections DS
    #
    #    spliceElement_all        = 1 -> collect splice data
    #                               0 -> do not collect splice data
    #    splice_list_x_all        = list of 2D np.array indicating the pier and story with splice in the X frame
    #    splice_list_y_all        = list of 2D np.array indicating the pier and story with splice in the Y frame
    #    column_list_x_all        = list of 2D np.array indicating which columns exist in the X frame
    #    column_list_y_all        = list of 2D np.array indicating which column exist in the X frame
    #    minrdrift                = minimum residual drift to collect
    #    splice_frac_strain       = strain limit for deciding fracture occured on splices
    #    drift_out          = Method to output peak drift
    #                         -> 'abs' = multiple columns with the peak absolute value for each floor
    #                         -> 'both' = multiple columns with the peak positive an negative value for each floor
    #    rdrift_out         = Method to output residual drift
    #                         -> 'max' = single column with the maximum residual across floors
    #                         -> 'all_abs' = multiple columns with the residual absolute value for each floor
    #                         -> 'all' = multiple columns with the residual for each floor with its sign
    #

    # Parse case to execute
    model_name = model_name_all[case_i]
    stripe_folder = stripe_folder_all[case_i]
    save_results_folder = save_results_folder_all[case_i]
    msa_folder = msa_folder_all[case_i]

    spliceElement = splice_all[case_i]
    beam_list = beam_list_all[case_i]
    column_list = column_list_all[case_i]
    splice_list = splice_list_all[case_i]


    # Define path to save results
    results_filename = os.path.join(save_results_folder, 'EDP_' + model_name + '_' + stripe_folder + '.csv')

    #### collect results on singleDir ####
    stripe_folder_path = os.path.join(msa_folder, stripe_folder)
    results = collect_gmset_response(stripe_folder_path, beam_list, fracElement, 1, spliceElement,
                                     splice_list, column_list, drift_out=drift_out, rdrift_out=rdrift_out, minrdrift=minrdrift,
                                     splice_frac_strain=splice_frac_strain)

    results.to_csv(results_filename)


def collect_single_response(model_name_all, stripe_folder_all, save_results_folder_all, msa_folder_all, beam_list_x_all,
                            beam_list_y_all, fracElement, spliceElement_all, splice_list_x_all, splice_list_y_all,
                            column_list_x_all,
                            column_list_y_all, minrdrift, splice_frac_strain, drift_out, rdrift_out, case_i):
    # INPUTS
    # Collects the EDP results considering each stripe of each case as an independent job
    #    model_name_all           = list of str with the case name to collect results from
    #    stripe_folder_all        = list of str with the foldername of the stripe to collect results from
    #    save_results_folder_all  = list of str with path to save results
    #    msa_folder_all          = list of list [path_to_results_X, path_to_results_Y]
    #    beam_list_x_all          = list of 2D np.array indicating which beams exist in the X frame
    #    beam_list_Y_all          = list of 2D np.array indicating which beams exist in the Y frame
    #    fracElement              = true  -> collect connections DS
    #                               false -> does NOT collect connections DS
    #
    #    spliceElement_all        = 1 -> collect splice data
    #                               0 -> do not collect splice data
    #    splice_list_x_all        = list of 2D np.array indicating the pier and story with splice in the X frame
    #    splice_list_y_all        = list of 2D np.array indicating the pier and story with splice in the Y frame
    #    column_list_x_all        = list of 2D np.array indicating which columns exist in the X frame
    #    column_list_y_all        = list of 2D np.array indicating which column exist in the X frame
    #    minrdrift                = minimum residual drift to collect
    #    splice_frac_strain       = strain limit for deciding fracture occured on splices
    #    drift_out          = Method to output peak drift
    #                         -> 'abs' = multiple columns with the peak absolute value for each floor
    #                         -> 'both' = multiple columns with the peak positive an negative value for each floor
    #    rdrift_out         = Method to output residual drift
    #                         -> 'max' = single column with the maximum residual across floors
    #                         -> 'all_abs' = multiple columns with the residual absolute value for each floor
    #                         -> 'all' = multiple columns with the residual for each floor with its sign
    #

    # Parse case to execute
    model_name = model_name_all[case_i]
    dirCase = model_name.split('dir')[1][0]
    stripe_folder = stripe_folder_all[case_i]
    save_results_folder = save_results_folder_all[case_i]
    msa_folder = msa_folder_all[case_i]

    if dirCase == 'X':
        spliceElement = spliceElement_all[case_i]
        beam_list = beam_list_x_all[case_i]
        column_list = column_list_x_all[case_i]
        splice_list = splice_list_x_all[case_i]
    else:
        spliceElement = spliceElement_all[case_i]
        beam_list = beam_list_y_all[case_i]
        column_list = column_list_y_all[case_i]
        splice_list = splice_list_y_all[case_i]

    # Define path to save results
    results_filename = os.path.join(save_results_folder, 'EDP_' + model_name + '_' + stripe_folder + '.csv')

    #### collect results on singleDir ####
    stripe_folder_path = os.path.join(msa_folder, stripe_folder)
    results = collect_gmset_response(stripe_folder_path, beam_list, fracElement, 1, spliceElement,
                                     splice_list, column_list, drift_out=drift_out, rdrift_out=rdrift_out, minrdrift=minrdrift,
                                     splice_frac_strain=splice_frac_strain)

    results.to_csv(results_filename)

def get_pz_response_time(results_folder, beam_list, column_list, filenames, res_type='Max', t=0):
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
        filepath = os.path.join(results_folder, file + '.out')

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

def get_pz_response(results_folder, pz_list, filenames):
    # Read response for panel zones, currently takes the maximum of the time history
    #
    # INPUTS
    #    results_folder = path to folder with the results of NLRHA
    #    pz_list      = 2D np.array with 1 or 0 for the pz that exist
    #    filenames      = list with any group of the following alternatives
    #                     'pz_rot'
    #                     'all_disp': include time vector
    #
    # OUTPUTS
    #    pz_results = dictionary with all results for the panel zones
    #

    pz_results = dict(keys=filenames)
    n_stories, n_pier = pz_list.shape
    num_pz = np.sum(pz_list)

    # Read results as 1d array
    for file in filenames:
        filepath = os.path.join(results_folder, file + '.out')
        # Read requested data (always at end-2 of analysis to take the last full result in case of inconvergence)
        with open(filepath) as f:
            last_line = 0
            prev_line = 0
            pp_line = 0
            for line in f:
                ppp_line = pp_line
                pp_line = prev_line
                prev_line = last_line
                if line == '\n' or type(line) == int: # skip blank lines
                    last_line = last_line
                else:
                    last_line = line
            aux = last_line.split()  # read second to last line in a time history since sometimes has errors
            try:
                aux = [float(x) for x in aux]  # convert to list of floats
            except:
                aux = np.array([0, 0])
            # only keeps set of results that include all connections (considering last 4 lines as options)
            if (file == 'pz_rot' and len(aux) < num_pz) or \
                    (file == 'all_disp' and len(aux) < 1 + num_pz):
                try:
                    aux = prev_line.split()
                    aux = [float(x) for x in aux]  # convert to list of floats
                except:
                    aux = np.array([0, 0])
                if (file == 'pz_rot' and len(aux) < num_pz) or \
                        (file == 'all_disp' and len(aux) < 1 + num_pz):
                    try:
                        aux = pp_line.split()
                        aux = [float(x) for x in aux]  # convert to list of floats
                    except:
                        aux = np.array([0, 0])
                    if (file == 'pz_rot' and len(aux) < num_pz) or \
                        (file == 'all_disp' and len(aux) < 1 + num_pz):
                        try:
                            aux = ppp_line.split()
                            aux = [float(x) for x in aux]  # convert to list of floats
                        except:
                            aux = np.array([0, 0])

            if file == 'all_disp':
                aux = aux[1:]
                aux = aux[0:num_pz]
                results_1d = np.abs(aux)
            if file == 'pz_rot':
                aux = aux[0:num_pz]
                results_1d = np.abs(aux)

        # If still not complete row of results fills the missing values with zeros
        # This work around is not bad because this occurs on collapsed cases
        if (file == 'pz_rot' and len(results_1d) < num_pz) or \
                    (file == 'all_disp' and len(results_1d) < num_pz):
            print('WARNING:Autocompleted PZ results: ' + results_folder)
            print('length of vector = ' + str(len(aux)) + '; should be = ' + str(num_pz))
            aux2 = np.zeros(num_pz)
            aux2[0:len(results_1d)] = results_1d
            results_1d = aux2

        # Initialize final matrix to return the results
        pz_results[file] = np.zeros([n_stories, n_pier])

        # Save in desired format
        i_element = 0
        for i_story in range(n_stories):
            for i_pier in range(n_pier):
                if pz_list[i_story, i_pier] > 0:
                    pz_results[file][i_story, i_pier] = results_1d[i_element]
                    i_element += 1

    return pz_results

def get_column_response_time(results_folder, beam_list, column_list, filenames, res_type='Max', t=0, def_desired='rot'):
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
        filepath = os.path.join(results_folder, file + '.out')

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

def get_column_response(results_folder, column_list, filenames, def_desired='rot'):
    # Read response for columns, currently takes the maximum of the time history
    #
    # INPUTS
    #    results_folder = path to folder with the results of NLRHA
    #    beam_list      = 2D np.array with 1 or 0 for the beams that exist
    #    column_list    = 2D np.array with 1 or 0 for the columns that exist
    #    filenames      = list with any group of the following alternatives
    #                     'hinge_bot'
    #                     'hinge_top'
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
        filepath = os.path.join(results_folder, file + '.out')

        # Read requested data (always at end-2 of analysis)
        with open(filepath) as f:
            last_line = 0
            prev_line = 0
            pp_line = 0
            for line in f:
                ppp_line = pp_line
                pp_line = prev_line
                prev_line = last_line
                if line == '\n'or type(line) == int:  # skip blank lines
                    last_line = last_line
                else:
                    last_line = line
            # try:
            aux = last_line.split()  # read last line in a time history
            # except:
                # print('ERROR: ' + filepath)

            try:
                aux = [float(x) for x in aux]  # convert to list of floats
            except:
                aux = np.array([0, 0])
            # only keeps lines with results for all the columns (possible issues when inconvergence)
            if ((len(aux) != int(3 * num_columns)) or (len(aux) != int(6 * num_columns)) or
                    (len(aux) != int(num_columns))):
                try:
                    aux = prev_line.split()
                    aux = [float(x) for x in aux]  # convert to list of floats
                except:
                    aux = np.array([0, 0])
                if ((len(aux) != int(3 * num_columns)) or (len(aux) != int(6 * num_columns)) or
                        (len(aux) != int(num_columns))):
                    try:
                        aux = pp_line.split()
                        aux = [float(x) for x in aux]  # convert to list of floats
                    except:
                        aux = np.array([0, 0])
                    if ((len(aux) != int(3 * num_columns)) or (len(aux) != int(6 * num_columns)) or
                            (len(aux) != int(num_columns))):
                        try:
                            aux = ppp_line.split()  # read second to last line in a time history since sometimes has errors
                            aux = [float(x) for x in aux]  # convert to list of floats
                        except:
                            aux = np.array([0, 0])
            data_1d = np.abs(aux)

        # If still not complete row of results fills the missing values with zeros
        # This work around is not bad because this occurs on collapsed cases
        if len(data_1d) < int(num_columns):
            print('WARNING:Autocompleted ' + file + ' results: ' + results_folder)
            print('length of vector = ' + str(len(data_1d)) + '; should be = ' + str(num_columns))
            aux2 = np.zeros(num_columns)
            aux2[0:len(data_1d)] = data_1d
            data_1d = aux2
        elif (len(data_1d) < int(3 * num_columns)) and (len(data_1d) != int(num_columns)):
            print('WARNING:Autocompleted ' + file + ' results: ' + results_folder)
            print('length of vector = ' + str(len(data_1d)) + '; should be = ' + str(3*num_columns))
            aux2 = np.zeros(3*num_columns)
            aux2[0:len(data_1d)] = data_1d
            data_1d = aux2
        elif (len(data_1d) < int(6 * num_columns)) and (len(data_1d) != int(num_columns)) and \
                (len(data_1d) != int(num_columns)):
            print('WARNING:Autocompleted ' + file + ' results: ' + results_folder)
            print('length of vector = ' + str(len(data_1d)) + '; should be = ' + str(6*num_columns))
            aux2 = np.zeros(6 * num_columns)
            aux2[0:len(data_1d)] = data_1d
            data_1d = aux2

        n_cols = len(data_1d)

        if n_cols == int(3 * num_columns):
            # read axial def, shear def, rotation for each hinge
            axial_def = data_1d[0:n_cols:3]
            shear_def = data_1d[1:n_cols:3]
            rot = data_1d[2:n_cols:3]

            if def_desired == 'axial':
                results_1d = axial_def
            elif def_desired == 'shear':
                results_1d = shear_def
            else:
                results_1d = rot

        elif n_cols == int(6 * num_columns):
            # read moment for each hinge
            M_bot = data_1d[2:n_cols:6]
            M_top = data_1d[5:n_cols:6]

            # read response at index t for each hinge
            if 'bot' in file:
                results_1d = abs(M_bot)
            elif 'top' in file:
                results_1d = abs(M_top)

        elif n_cols == num_columns:
            results_1d = data_1d

        else:
            print('ERROR: output not consistent with number of columns')
            print(results_folder)
            print(file)
            print('n_cols = ' + str(n_cols) + '; num_columns = ' + str(num_columns))

        # Initialize final matrix to return the results
        column_results[file] = np.zeros([n_stories, n_pier])

        # Save in desired format
        i_element = 0
        for i_story in range(n_stories):
            for i_pier in range(n_pier):
                if column_list[i_story, i_pier] > 0:  # jump if element does not exist in model setbacks
                    # if i_story == 0 or beam_list[
                    #     i_story - 1, min(i_pier, n_pier - 2)]:  # jump columns already created in atriums (no need since the column_list vector already includes this info)

                        column_results[file][i_story, i_pier] = results_1d[i_element]
                        i_element += 1

    return column_results

def get_beam_response_time(results_folder, beam_list, filenames, res_type='Max', t=0, def_desired='rot'):
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
        filepath = os.path.join(results_folder, file + '.out')

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

def get_beam_response(results_folder, beam_list, filenames, def_desired='rot'):
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
        filepath = os.path.join(results_folder, file + '.out')

        # Read requested data (always at end-2 of analysis)
        with open(filepath) as f:
            last_line = 0
            prev_line = 0
            pp_line = 0
            for line in f:
                ppp_line = pp_line
                pp_line = prev_line
                prev_line = last_line
                if line == '\n' or type(line) == int:  # skip blank lines
                    last_line = last_line
                else:
                    last_line = line

            # try:
            aux = last_line.split()  # read last line in a time history
            # except:
            #     print('ERROR: ' + filepath)

            try:
                aux = [float(x) for x in aux]  # convert to list of floats
            except:
                aux = np.array([0, 0])
            # only keeps lines with results for all the columns (possible issues when inconvergence)
            if (len(aux) != int(3 * num_beams)) or (len(aux) != int(num_beams)):
                try:
                    aux = prev_line.split()
                    aux = [float(x) for x in aux]  # convert to list of floats
                except:
                    aux = np.array([0, 0])
                if (len(aux) != int(3 * num_beams)) or (len(aux) != int(num_beams)):
                    try:
                        aux = pp_line.split()
                        aux = [float(x) for x in aux]  # convert to list of floats
                    except:
                        aux = np.array([0, 0])
                    if (len(aux) != int(3 * num_beams)) or (len(aux) != int(num_beams)):
                        try:
                            aux = ppp_line.split()
                            aux = [float(x) for x in aux]  # convert to list of floats
                        except:
                            aux = np.array([0, 0])
            aux = [float(x) for x in aux]  # convert to list of floats
            data_1d = np.abs(aux)

        n_cols = len(data_1d)

        if n_cols == 3 * num_beams:  # file == 'hinge_left' or file == 'hinge_right':
            # read axial def, shear def, rotation for each hinge
            axial_def = data_1d[0:n_cols:3]
            shear_def = data_1d[1:n_cols:3]
            rot = data_1d[2:n_cols:3]

            if def_desired == 'axial':
                results_1d = axial_def
            elif def_desired == 'shear':
                results_1d = shear_def
            else:
                results_1d = rot

        elif n_cols == num_beams:
            results_1d = data_1d
        else:
            print('ERROR: output not consistent with number of beams')
            print(file)
            print('n_cols = ' + str(n_cols) + '; num_beams = ' + str(num_beams))
            beam_results = np.ones(num_beams) * np.nan
            return beam_results

        # Initialize final matrix to return the results
        beam_results[file] = np.zeros([n_stories, n_bays])

        # Save in desired format
        i_element = 0
        for i_story in range(n_stories):
            for i_beam in range(n_bays):
                if beam_list[i_story, i_beam] > 0:
                    beam_results[file][i_story, i_beam] = results_1d[i_element]
                    i_element += 1

    return beam_results



def get_splice_response_time(results_folder, splice_list, beam_list, column_list, filenames, res_type='Max', t=0,
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
        filepath = os.path.join(results_folder, file + '.out')

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

def get_splice_response(results_folder, splice_list, column_list, filenames, res_type='Max',
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
    #                       'at_end': return the response at end of the history
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
    max_res = 0

    # Read results as 1d array
    for file in filenames:
        filepath = os.path.join(results_folder, file + '.out')

        # data_1d = np.loadtxt(filepath)
        # _, n_cols = data_1d.shape
        with open(filepath) as f:
            last_line = 0
            for line in f:
                prev_line = last_line
                try:
                    aux = line.split()
                    aux = [abs(float(x)) for x in aux]  # convert to list of floats, empty "line" gives an error here

                    # Initialize max_res vector if not exist yet
                    if type(max_res) == int:
                        max_res = np.zeros(len(aux))

                    # only keep row with complete data
                    if ((len(aux) == int(2 * num_splices)) or (len(aux) == int(10 * num_splices)) or
                            (len(aux) == int(3 * num_splices)) or (len(aux) == int(6 * num_splices)) or
                            (len(aux) == int(num_splices))):
                        last_line = line
                        max_res = np.max([max_res, aux], axis=0)
                    else:
                        last_line = last_line
                except:
                    last_line = last_line

            if res_type == 'Max':
                # Take the max value in the history
                data_1d = max_res
            else:
                # Taking last value
                aux = prev_line.split()
                aux = [float(x) for x in aux]  # convert to list of floats
                data_1d = np.abs(aux)

        n_cols = len(data_1d)

        if n_cols == int(2 * num_splices):
            # read stress and strain for a unique section
            stress = data_1d[0:n_cols:2]
            strain = data_1d[1:n_cols:2]

            if def_desired == 'stress':
                res = stress
            elif def_desired == 'strain':
                res = strain
            else:
                print('ERROR: specify either "stress" or "strain" output')

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

            results_1d = res

        elif n_cols == int(6 * num_splices):
            # read moment for each hinge
            M_bot = data_1d[:, 2:n_cols:6]
            M_top = data_1d[:, 5:n_cols:6]

            # read response history
            if 'bot' in file:
                aux = M_bot
            elif 'top' in file:
                aux = M_top

        elif n_cols == num_splices:
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
        # i_element = 0
        # for i_pier in range(n_pier):
        #     for i_story in range(n_stories):
        #         if column_list[i_story, i_pier] > 0:  # jump if setbacks
        #             if i_story == 0 or beam_list[
        #                 i_story - 1, min(i_pier, n_pier - 2)]:  # jump columns already created in atriums
        #                 if splice_list[i_story, i_pier] > 0:  # jump if no splice in this story
        #                     if res_type == 'all_t':
        #                         column_results[file][i_story, i_pier, :] = results_1d[:, i_element]
        #                     else:
        #                         column_results[file][i_story, i_pier] = results_1d[i_element]
        #
        #                     i_element += 1
        i_element = 0
        for i_pier in range(n_pier):
            for i_story in range(n_stories):
                if splice_list[i_story, i_pier] > 0:
                # jump if no splice in this column segment. The splice_list array already accounts for setbacks, atriums or missing columns
                    if res_type == 'all_t':
                        column_results[file][i_story, i_pier, :] = results_1d[:, i_element]
                    else:
                        column_results[file][i_story, i_pier] = results_1d[i_element]

                    i_element += 1

    return column_results


def collect_endState_single_response(model_name_all, save_results_folder_all, stripe_folders_all, msa_folder_all,
                                     beam_list_x_all,
                                     beam_list_y_all, column_list_x_all, column_list_y_all, pz_list_x_all,
                                     pz_list_y_all, splice_all, colSplice_x_all,
                                     colSplice_y_all, case_i):
    # INPUTS
    # All the inputs include information per case (different from the EDP collector that breaks each case into independent jobs per stripe
    #    model_name_all           = list of str with the case name to collect results from
    #    save_results_folder_all  = list of str with path to save results
    #    stripe_folders_all       = list of list with the folder name of each stripe
    #    msa_folder_all          = list of list [path_to_results_X, path_to_results_Y]
    #    beam_list_x_all          = list of 2D np.array indicating which beams exist in the X frame
    #    beam_list_Y_all          = list of 2D np.array indicating which beams exist in the Y frame
    #    column_list_x_all        = list of 2D np.array indicating which columns exist in the X frame
    #    column_list_y_all        = list of 2D np.array indicating which columns exist in the Y frame
    #    pz_list_x_all            = list of 2D np.array indicating which pz exist in the X frame
    #    pz_list_y_all            = list of 2D np.array indicating which pz exist in the Y frame
    #    splice_all               = list of boolean if splice are considered or ignored
    #    colSplice_x_all          = list of 2D np.array indicating which stories have a splice in the X frame
    #    colSplice_y_all          = list of 2D np.array indicating which stories have a splice in the X frame
    #

    # Parse case to execute
    model_name = model_name_all[case_i]
    dirCase = model_name.split('dir')[1][0]
    save_results_folder = save_results_folder_all[case_i]
    stripe_folders = stripe_folders_all[case_i]
    msa_folder = msa_folder_all[case_i]
    beam_list_x = beam_list_x_all[case_i]
    beam_list_y = beam_list_y_all[case_i]
    column_list_x = column_list_x_all[case_i]
    column_list_y = column_list_y_all[case_i]
    pz_list_x = pz_list_x_all[case_i]
    pz_list_y = pz_list_y_all[case_i]
    splice = splice_all[case_i]
    if splice == 1:
        colSplice_x = colSplice_x_all[case_i]
        colSplice_y = colSplice_y_all[case_i]

    n_stripes = len(stripe_folders)

    # Collect end state for every gm in every return period for GIVEN DIRECTIONS
    print('------- ' + model_name + ' FRAME IN ' + dirCase + ' -------')

    # Select frame geometry matrices
    if dirCase == 'X':
        beam_list = beam_list_x
        column_list = column_list_x
        pz_list = pz_list_x
        if splice == 1:
            colSplice = colSplice_x
    else:
        beam_list = beam_list_y
        column_list = column_list_y
        pz_list = pz_list_y
        if splice == 1:
            colSplice = colSplice_y
    results_filename = os.path.join(save_results_folder, 'end_state_' + model_name + '_dir' + dirCase + '.h5')

    # # count panel zones
    n_stories, n_pier = column_list.shape
    # num_pz = 0
    # for i_story in range(n_stories):
    #     for i_pier in range(n_pier):
    #         if ((column_list[min(i_story + 1, n_stories-1), i_pier] == 1) or
    #                 ((column_list[i_story, i_pier] == 1 )) and
    #                 (beam_list[i_story, i_pier - 1])):
    #             existPZ = True
    #         elif ((column_list[min(i_story + 1, n_stories-1), i_pier] == 1) or
    #                 ((column_list[i_story, i_pier] == 1 ) and
    #                  (beam_list[i_story, min(i_pier, n_pier -2)]))):
    #             existPZ = True
    #         else:
    #             existPZ = False
    #
    #         if existPZ:
    #             num_pz += 1
    # print('num_pz='+str(num_pz))

    # Removes existing file
    # if os.path.isfile(results_filename):
    #     os.remove(results_filename)
    #     print(results_filename + ' already exists, so deleted it')

    # if True: (Collects only data for those building without data)
    if not os.path.isfile(results_filename):

        # Collect results and store in HDF file
        with h5py.File(results_filename, 'w') as hf:
            # prepare data groups per return period
            for group in stripe_folders:
                _ = hf.create_group('/' + group)

            # collect bldg response for each gm in each stripe
            for i in range(n_stripes):
                stripe_folder_path = os.path.join(msa_folder, stripe_folders[i])

                print('RP = ' + str(stripe_folders[i]) + 'years')
                # print(stripe_folder_path)

                gm_ids = os.listdir(stripe_folder_path)
                for j in range(len(gm_ids)):
                    # print(gm_ids[j])

                    # collect results for this gm
                    results_gm = os.path.join(stripe_folder_path, gm_ids[j])

                    # check if acc results available (gm finished?)
                    pfa_gm = get_EDPstory_response(results_gm, n_stories, 'acc_env')
                    if type(pfa_gm) == int:  # did not finish RHA, so skip the ground motion
                        print('Did not finish GM' + str(gm_ids[j]))
                    else:
                        #    Panel zones
                        # pz_response     = get_pz_response(results_gm, beam_list, column_list, num_pz, ['all_disp', 'pz_rot'])
                        pz_response = get_pz_response(results_gm, pz_list, ['all_disp', 'pz_rot'])
                        #    beams and columns
                        if 'cvn' in model_name:
                            column_response = get_column_response(results_gm, column_list, ['hinge_bot', 'hinge_top'])
                            beam_plas_rot = get_beam_response(results_gm, beam_list, ['hinge_left', 'hinge_right'])
                            frac_simulated = get_beam_response(results_gm, beam_list,
                                                               ['frac_LB', 'frac_LT', 'frac_RB', 'frac_RT'])
                            FI_simulated = get_beam_response(results_gm, beam_list,
                                                               ['FI_LB', 'FI_LT', 'FI_RB', 'FI_RT'])
                        else:
                            beam_plas_rot = get_beam_response(results_gm, beam_list, ['hinge_left', 'hinge_right'])
                            column_response = get_column_response(results_gm, column_list, ['hinge_bot', 'hinge_top'])
                        #    Splices
                        if splice == 1:
                            splice_response = get_splice_response(results_gm, colSplice, column_list, ['ss_splice'],
                                                                  res_type='Max', def_desired='strain')
                            splice_frac = splice_response['ss_splice'] > 2 * 60 / 29000

                        # create gm group
                        rp_group = hf['/' + stripe_folders[i]]
                        gm_record_group = rp_group.create_group(gm_ids[j])

                        # Save in h5 file's building_group
                        if 'cvn' in model_name:
                            key = 'all_disp'
                            _ = gm_record_group.create_dataset(key, data=pz_response[key])
                            key = 'pz_rot'
                            _ = gm_record_group.create_dataset(key, data=pz_response[key])
                            key = 'hinge_bot'
                            _ = gm_record_group.create_dataset(key, data=column_response[key])
                            key = 'hinge_top'
                            _ = gm_record_group.create_dataset(key, data=column_response[key])
                            key = 'hinge_left'
                            _ = gm_record_group.create_dataset(key, data=beam_plas_rot[key])
                            key = 'hinge_right'
                            _ = gm_record_group.create_dataset(key, data=beam_plas_rot[key])
                            key = 'frac_LB'
                            _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                            key = 'frac_LT'
                            _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                            key = 'frac_RB'
                            _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                            key = 'frac_RT'
                            _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                            key = 'FI_LB'
                            _ = gm_record_group.create_dataset(key, data=FI_simulated[key])
                            key = 'FI_LT'
                            _ = gm_record_group.create_dataset(key, data=FI_simulated[key])
                            key = 'FI_RB'
                            _ = gm_record_group.create_dataset(key, data=FI_simulated[key])
                            key = 'FI_RT'
                            _ = gm_record_group.create_dataset(key, data=FI_simulated[key])
                            if splice == 1:
                                key = 'ss_splice'
                                _ = gm_record_group.create_dataset(key, data=splice_response[key])
                                key = 'splice_frac'
                                _ = gm_record_group.create_dataset(key, data=splice_frac)
                        else:
                            key = 'all_disp'
                            _ = gm_record_group.create_dataset(key, data=pz_response[key])
                            key = 'pz_rot'
                            _ = gm_record_group.create_dataset(key, data=pz_response[key])
                            key = 'hinge_bot'
                            _ = gm_record_group.create_dataset(key, data=column_response[key])
                            key = 'hinge_top'
                            _ = gm_record_group.create_dataset(key, data=column_response[key])
                            key = 'hinge_left'
                            _ = gm_record_group.create_dataset(key, data=beam_plas_rot[key])
                            key = 'hinge_right'
                            _ = gm_record_group.create_dataset(key, data=beam_plas_rot[key])
                            if splice == 1:
                                key = 'ss_splice'
                                _ = gm_record_group.create_dataset(key, data=splice_response[key])
                                key = 'splice_frac'
                                _ = gm_record_group.create_dataset(key, data=splice_frac)




def collect_endStateXandY_response(model_name_all, save_results_folder_all, stripe_folders_all, msa_folders_all, beam_list_x_all,
                                   beam_list_y_all, column_list_x_all, column_list_y_all, pz_list_x_all, pz_list_y_all, splice_all, colSplice_x_all,
                                   colSplice_y_all, case_i):
    # INPUTS
    # All the inputs include information per case (different from the EDP collector that breaks each case into independent jobs per stripe
    #    model_name_all           = list of str with the case name to collect results from
    #    save_results_folder_all  = list of str with path to save results
    #    stripe_folders_all       = list of list with the folder name of each stripe
    #    msa_folders_all          = list of list [path_to_results_X, path_to_results_Y]
    #    beam_list_x_all          = list of 2D np.array indicating which beams exist in the X frame
    #    beam_list_Y_all          = list of 2D np.array indicating which beams exist in the Y frame
    #    column_list_x_all        = list of 2D np.array indicating which columns exist in the X frame
    #    column_list_y_all        = list of 2D np.array indicating which columns exist in the Y frame
    #    pz_list_x_all            = list of 2D np.array indicating which pz exist in the X frame
    #    pz_list_y_all            = list of 2D np.array indicating which pz exist in the Y frame
    #    splice_all               = list of boolean if splice are considered or ignored
    #    colSplice_x_all          = list of 2D np.array indicating which stories have a splice in the X frame
    #    colSplice_y_all          = list of 2D np.array indicating which stories have a splice in the X frame
    #

    # Parse case to execute
    model_name    = model_name_all[case_i]
    save_results_folder = save_results_folder_all[case_i]
    stripe_folders= stripe_folders_all[case_i]
    msa_folders   = msa_folders_all[case_i]
    beam_list_x   = beam_list_x_all[case_i]
    beam_list_y   = beam_list_y_all[case_i]
    column_list_x = column_list_x_all[case_i]
    column_list_y = column_list_y_all[case_i]
    pz_list_x     = pz_list_x_all[case_i]
    pz_list_y     = pz_list_y_all[case_i]
    splice        = splice_all[case_i]
    if splice == 1:
        colSplice_x = colSplice_x_all[case_i]
        colSplice_y = colSplice_y_all[case_i]

    dirCases = ['X', 'Y']
    n_stripes = len(stripe_folders)
    # Collect end state for every gm in every return period for BOTH DIRECTIONS
    for dir_i in range(len(dirCases)):

        print('------- ' + model_name + ' FRAME IN ' + dirCases[dir_i] + ' -------')

        # Select frame geometry matrices
        if dir_i == 0:
            beam_list   = beam_list_x
            column_list = column_list_x
            pz_list = pz_list_x
            if splice == 1:
                colSplice = colSplice_x
        else:
            beam_list   = beam_list_y
            column_list = column_list_y
            pz_list = pz_list_y
            if splice == 1:
                colSplice = colSplice_y
        results_filename = os.path.join(save_results_folder, 'end_state_' + model_name + '_dir'+ dirCases[dir_i] +'.h5')

        # # count panel zones
        n_stories, n_pier = column_list.shape
        # num_pz = 0
        # for i_story in range(n_stories):
        #     for i_pier in range(n_pier):
        #         if ((column_list[min(i_story + 1, n_stories-1), i_pier] == 1) or
        #                 ((column_list[i_story, i_pier] == 1 )) and
        #                 (beam_list[i_story, i_pier - 1])):
        #             existPZ = True
        #         elif ((column_list[min(i_story + 1, n_stories-1), i_pier] == 1) or
        #                 ((column_list[i_story, i_pier] == 1 ) and
        #                  (beam_list[i_story, min(i_pier, n_pier -2)]))):
        #             existPZ = True
        #         else:
        #             existPZ = False
        #
        #         if existPZ:
        #             num_pz += 1
        # print('num_pz='+str(num_pz))

        # # Removes existing file
        # if os.path.isfile(results_filename):
        #     os.remove(results_filename)
        #     print(results_filename + ' already exists, so deleted it')

        # if True (Collects only data for those building without data)
        if not os.path.isfile(results_filename):

            # Collect results and store in HDF file
            with h5py.File(results_filename, 'w') as hf:
                # prepare data groups per return period
                for group in stripe_folders:
                    _ = hf.create_group('/' + group)

                # collect bldg response for each gm in each stripe
                for i in range(n_stripes):
                    stripe_folder_path = os.path.join(msa_folders[dir_i], stripe_folders[i])

                    print('RP = ' + str(stripe_folders[i]) + 'years')
                    # print(stripe_folder_path)

                    gm_ids = os.listdir(stripe_folder_path)
                    for j in range(len(gm_ids)):
                        # print(gm_ids[j])

                        # collect results for this gm
                        results_gm = os.path.join(stripe_folder_path, gm_ids[j])

                        # check if acc results available (gm finished?)
                        pfa_gm = get_EDPstory_response(results_gm, n_stories, 'acc_env')
                        if type(pfa_gm) == int:  # did not finish RHA, so skip the ground motion
                            print('Did not finish GM' + str(gm_ids[j]))
                        else:
                            #    Panel zones
                            # pz_response     = get_pz_response(results_gm, beam_list, column_list, num_pz, ['all_disp', 'pz_rot'])
                            pz_response = get_pz_response(results_gm, pz_list, ['all_disp', 'pz_rot'])
                            #    beams and columns
                            if 'cvn' in model_name:
                                column_response = get_column_response(results_gm, column_list, ['hinge_bot','hinge_top'])
                                beam_plas_rot = get_beam_response(results_gm, beam_list, ['hinge_left', 'hinge_right'])
                                frac_simulated  = get_beam_response(results_gm, beam_list, ['frac_LB','frac_LT','frac_RB','frac_RT'])
                            else:
                                beam_plas_rot   = get_beam_response(results_gm, beam_list, ['hinge_left','hinge_right'])
                                column_response = get_column_response(results_gm, column_list, ['hinge_bot','hinge_top'])
                            #    Splices
                            if splice == 1:
                                splice_response = get_splice_response(results_gm, colSplice, column_list, ['ss_splice'],
                                                  res_type='Max', def_desired='strain')
                                splice_frac = splice_response['ss_splice'] > 2*60/29000

                            # create gm group
                            rp_group = hf['/' + stripe_folders[i]]
                            gm_record_group = rp_group.create_group(gm_ids[j])

                            # Save in h5 file's building_group
                            if 'cvn' in model_name:
                                key = 'all_disp'
                                _ = gm_record_group.create_dataset(key, data=pz_response[key])
                                key = 'pz_rot'
                                _ = gm_record_group.create_dataset(key, data=pz_response[key])
                                key = 'hinge_bot'
                                _ = gm_record_group.create_dataset(key, data=column_response[key])
                                key = 'hinge_top'
                                _ = gm_record_group.create_dataset(key, data=column_response[key])
                                key = 'hinge_left'
                                _ = gm_record_group.create_dataset(key, data=beam_plas_rot[key])
                                key = 'hinge_right'
                                _ = gm_record_group.create_dataset(key, data=beam_plas_rot[key])
                                key = 'frac_LB'
                                _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                                key = 'frac_LT'
                                _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                                key = 'frac_RB'
                                _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                                key = 'frac_RT'
                                _ = gm_record_group.create_dataset(key, data=frac_simulated[key])
                                if splice == 1:
                                    key = 'ss_splice'
                                    _ = gm_record_group.create_dataset(key, data=splice_response[key])
                                    key = 'splice_frac'
                                    _ = gm_record_group.create_dataset(key, data=splice_frac)
                            else:
                                key = 'all_disp'
                                _ = gm_record_group.create_dataset(key, data=pz_response[key])
                                key = 'pz_rot'
                                _ = gm_record_group.create_dataset(key, data=pz_response[key])
                                key = 'hinge_bot'
                                _ = gm_record_group.create_dataset(key, data=column_response[key])
                                key = 'hinge_top'
                                _ = gm_record_group.create_dataset(key, data=column_response[key])
                                key = 'hinge_left'
                                _ = gm_record_group.create_dataset(key, data=beam_plas_rot[key])
                                key = 'hinge_right'
                                _ = gm_record_group.create_dataset(key, data=beam_plas_rot[key])
                                if splice == 1:
                                    key = 'ss_splice'
                                    _ = gm_record_group.create_dataset(key, data=splice_response[key])
                                    key = 'splice_frac'
                                    _ = gm_record_group.create_dataset(key, data=splice_frac)
