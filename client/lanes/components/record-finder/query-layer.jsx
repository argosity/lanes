import React from 'react';

import { observer }   from 'mobx-react';
import { action, observable, computed } from 'mobx';

import Heading from 'grommet/components/Heading';
import Layer   from 'grommet/components/Layer';
import Box     from 'grommet/components/Box';
import CloseIcon from 'grommet/components/icons/base/Close';
import Button   from 'grommet/components/Button';

import DataTable from '../data-table';
import QueryBuilder from '../query-builder';

@observer
export default class QueryLayer extends React.PureComponent {


    static propTypes = {
        title: React.PropTypes.string.isRequired,
        onClose: React.PropTypes.func.isRequired,
        onRecordSelect: React.PropTypes.func.isRequired,
    }

    onSearchClose() {

    }

    @action.bound
    onRecordSelect({ model }) {
        this.props.onRecordSelect(model);
    }

    render() {
        const { visible, query, onClose, title } = this.props;
        if (!visible) { return null; }

        return (
            <Layer
                closer
                pad="small"
            >

                <Box
                    direction='row'
                    justify='start'
                    align='center'
                    margin={{ top: 'small' }}
                    flex='grow'
                >
                    <Box flex="grow">
                        <Heading tag="h3" margin="none">Find {title}</Heading>
                    </Box>
                    <Button plain icon={<CloseIcon />} onClick={onClose} />
                </Box>
                <QueryBuilder query={query} autoFetch />
                <DataTable
                    onRowClick={this.onRecordSelect}
                    query={query} autoFetch
                    style={{ minHeight: 400 }}
                />
            </Layer>
        );
    }


}